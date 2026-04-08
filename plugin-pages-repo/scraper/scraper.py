import discord
import json
import os
import re
import asyncio
import sys
import logging
from datetime import datetime, timezone

TOKEN = os.getenv("DISCORD_TOKEN")
CHANNEL_ID = 551846012310782014
BASE_DIR = os.path.join(os.path.dirname(__file__), "..", "..")
DATA_DIR = os.path.join(BASE_DIR, "data")
PLUGINS_DIR = os.path.join(BASE_DIR, "plugins")
OUTPUT_PATH = os.path.join(DATA_DIR, "plugins.json")
API_PATH = os.path.join(DATA_DIR, "api.json")


def extract_loadstring_urls(code):
    if not code or not code.strip():
        return []
    urls = []
    patterns = [
        r'loadstring\s*\(\s*game\s*:\s*HttpGet\s*\(\s*["\']([^"\']+)["\']\s*\)',
        r'loadstring\s*\(\s*game\s*:\s*GetObjects\s*\(\s*["\']([^"\']+)["\']\s*\)',
        r'loadstring\s*\(\s*httpGet\s*\(\s*["\']([^"\']+)["\']\s*\)',
        r'loadstring\s*\(\s*readfile\s*\(\s*["\']([^"\']+)["\']\s*\)',
    ]
    for pat in patterns:
        for match in re.findall(pat, code, re.IGNORECASE):
            if match not in urls:
                urls.append(match)
    return urls


def extract_plugin_name(plugin):
    for att in plugin["files"]:
        if att["is_plugin"]:
            name = att["filename"]
            name = re.sub(r'\.(iy)$', '', name, flags=re.IGNORECASE)
            return name
    if plugin["description"]:
        first_line = plugin["description"].split('\n')[0].strip()
        first_line = re.sub(r'[*_~`#]', '', first_line).strip()
        if first_line and len(first_line) < 100:
            return first_line
    if plugin["files"]:
        return plugin["files"][0]["filename"]
    return f"Plugin #{plugin['id'][-6:]}"


class PluginScraper(discord.Client):
    def __init__(self):
        super().__init__()
        self.plugins = []
        self.existing_plugins = {}
        self.load_existing_plugins()

    def load_existing_plugins(self):
        if os.path.exists(OUTPUT_PATH):
            try:
                with open(OUTPUT_PATH, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    for p in data.get("plugins", []):
                        if "id" in p:
                            self.existing_plugins[str(p["id"])] = p
                    print(f"Loaded {len(self.existing_plugins)} existing plugins for code reuse.")
            except Exception as e:
                print(f"Could not load existing plugins: {e}")

    async def on_ready(self):
        print(f"Logged in as {self.user} (ID: {self.user.id})")
        print(f"Fetching plugins from channel {CHANNEL_ID}...")

        try:
            channel = self.get_channel(CHANNEL_ID)
            if channel is None:
                channel = await self.fetch_channel(CHANNEL_ID)
            if channel is None:
                print(f"ERROR: Could not find channel {CHANNEL_ID}")
                await self.close()
                return

            print(f"Found channel: #{channel.name}")

            message_count = 0
            new_plugins = 0
            async for message in channel.history(limit=None, oldest_first=True):
                message_count += 1
                existing = self.existing_plugins.get(str(message.id))
                plugin = await self.parse_message(message, existing)
                if plugin:
                    self.plugins.append(plugin)
                    if not existing:
                        new_plugins += 1
                if message_count % 100 == 0:
                    print(f"  Processed {message_count} messages, {new_plugins} new plugins...")

            print(f"\nDone! Processed {message_count} messages.")
            print(f"New: {new_plugins} | Total: {len(self.plugins)} plugins.")
            self.save_all()

        except discord.Forbidden:
            print("ERROR: No permission to access this channel.")
        except discord.NotFound:
            print("ERROR: Channel not found.")
        except Exception as e:
            print(f"ERROR: {e}")

        await self.close()

    async def parse_message(self, message, existing=None):
        if message.type not in (discord.MessageType.default, discord.MessageType.reply):
            return None
        if not message.attachments:
            return None
        if not any(att.filename.lower().endswith('.iy') for att in message.attachments):
            return None

        plugin = {
            "id": str(message.id),
            "name": "",
            "description": message.content or "",
            "author": {
                "name": message.author.display_name or message.author.name,
                "username": str(message.author),
                "avatar": str(message.author.display_avatar.url) if message.author.display_avatar else None,
            },
            "date": message.created_at.isoformat(),
            "message_url": message.jump_url,
            "files": [],
            "code_blocks": [],
            "links": [],
            "embeds": [],
            "reactions": [],
            "loadstring_urls": [],
        }

        for attachment in message.attachments:
            is_plugin = attachment.filename.lower().endswith('.iy')
            file_data = {
                "filename": attachment.filename,
                "url": f"plugins/{message.id}/{attachment.filename}",
                "size": attachment.size,
                "is_plugin": is_plugin,
            }
            
            plugin_dir = os.path.join(PLUGINS_DIR, str(message.id))
            filepath = os.path.join(plugin_dir, attachment.filename)
            
            try:
                if not (os.path.exists(filepath) and os.path.getsize(filepath) == attachment.size):
                    os.makedirs(plugin_dir, exist_ok=True)
                    await attachment.save(filepath)
            except Exception as e:
                print(f"Failed to save {attachment.filename}: {e}")
                file_data["url"] = attachment.url
                
            if is_plugin and attachment.size < 200_000:
                try:
                    existing_code = None
                    if existing:
                        for ext_att in existing.get("files", existing.get("attachments", [])):
                            if ext_att.get("filename") == attachment.filename and "code" in ext_att:
                                existing_code = ext_att["code"]
                                break
                    if existing_code:
                        file_data["code"] = existing_code
                    else:
                        with open(filepath, 'r', encoding='utf-8', errors='replace') as fh:
                            file_data["code"] = fh.read()
                except Exception:
                    pass
            plugin["files"].append(file_data)

        code_blocks = re.findall(r'```(?:lua)?\s*\n?(.*?)```', message.content, re.DOTALL)
        plugin["code_blocks"] = [b.strip() for b in code_blocks]

        urls = re.findall(r'https?://[^\s<>\]\)\"\'`]+', message.content)
        plugin["links"] = urls

        for embed in message.embeds:
            emb = {
                "type": embed.type,
                "url": embed.url,
                "title": embed.title,
                "description": embed.description,
                "color": hex(embed.color.value) if embed.color else None,
                "provider": {"name": embed.provider.name, "url": embed.provider.url} if embed.provider else None,
                "author": {"name": embed.author.name, "url": embed.author.url, "icon_url": embed.author.icon_url} if embed.author else None,
                "thumbnail": {"url": embed.thumbnail.proxy_url or embed.thumbnail.url} if embed.thumbnail else None,
                "image": {"url": embed.image.proxy_url or embed.image.url} if embed.image else None,
                "video": {"url": embed.video.url} if embed.video else None,
            }
            if any([emb["title"], emb["description"], emb["image"], emb["thumbnail"]]):
                plugin["embeds"].append(emb)

        for reaction in message.reactions:
            plugin["reactions"].append({
                "emoji": str(reaction.emoji),
                "count": reaction.count,
            })

        plugin["name"] = extract_plugin_name(plugin)

        all_code = []
        for f in plugin["files"]:
            if f.get("code"):
                all_code.append(f["code"])
        for cb in plugin["code_blocks"]:
            all_code.append(cb)
        plugin["loadstring_urls"] = extract_loadstring_urls("\n".join(all_code))

        return plugin

    def save_all(self):
        os.makedirs(DATA_DIR, exist_ok=True)
        os.makedirs(PLUGINS_DIR, exist_ok=True)
        files_saved = 0

        for plugin in self.plugins:
            for f in plugin["files"]:
                if f.get("is_plugin") and f.get("code"):
                    plugin_dir = os.path.join(PLUGINS_DIR, plugin["id"])
                    os.makedirs(plugin_dir, exist_ok=True)
                    filepath = os.path.join(plugin_dir, f["filename"])
                    with open(filepath, 'w', encoding='utf-8') as fh:
                        fh.write(f["code"])
                
                # Make sure the URL reflects local path for all files
                if f.get("url") and not f["url"].startswith("http"):
                    f["url"] = f"plugins/{plugin['id']}/{f['filename']}"
                files_saved += 1

        print(f"Processed {files_saved} files/media to {PLUGINS_DIR}")

        full_output = {
            "scraped_at": datetime.now(timezone.utc).isoformat(),
            "channel_id": str(CHANNEL_ID),
            "total_plugins": len(self.plugins),
            "plugins": self.plugins,
        }
        with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
            json.dump(full_output, f, indent=2, ensure_ascii=False)
        print(f"Saved {len(self.plugins)} plugins to {OUTPUT_PATH}")

        api_plugins = []
        for p in self.plugins:
            api_entry = {
                "id": p["id"],
                "name": p["name"],
                "author": p["author"]["name"],
                "date": p["date"],
                "files": [],
                "loadstring_urls": p["loadstring_urls"],
            }
            for f in p["files"]:
                api_entry["files"].append({
                    "filename": f["filename"],
                    "url": f["url"],
                    "size": f["size"],
                    "is_plugin": f["is_plugin"]
                })
            api_plugins.append(api_entry)

        api_output = {
            "version": "1.0",
            "updated_at": datetime.now(timezone.utc).isoformat(),
            "total": len(api_plugins),
            "plugins": api_plugins,
        }
        with open(API_PATH, 'w', encoding='utf-8') as f:
            json.dump(api_output, f, indent=2, ensure_ascii=False)
        print(f"Saved API ({len(api_plugins)} plugins) to {API_PATH}")


def main():
    if not TOKEN:
        print("ERROR: DISCORD_TOKEN environment variable not set.")
        return
    logging.basicConfig(level=logging.INFO)
    client = PluginScraper()
    print("Starting Infinite Yield Plugin Scraper...", flush=True)
    print(f"Target channel: {CHANNEL_ID}", flush=True)
    client.run(TOKEN)


if __name__ == "__main__":
    main()
