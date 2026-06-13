import discord
import json
import os
import re
import asyncio
import sys
import logging
import subprocess
from datetime import datetime, timezone

TOKEN = os.getenv("DISCORD_TOKEN")
CHANNEL_ID = 551846012310782014
BASE_DIR = os.path.join(os.path.dirname(__file__), "..", "..")
DATA_DIR = os.path.join(BASE_DIR, "data")
PLUGINS_DIR = os.path.join(BASE_DIR, "plugins")
OUTPUT_PATH = os.path.join(DATA_DIR, "plugins.json")
API_PATH = os.path.join(DATA_DIR, "api.json")


VIDEO_EXTS = ('.mp4', '.webm', '.mov', '.avi', '.mkv')

def compress_video(src, dst, max_bytes):
    try:
        result = subprocess.run(
            ['ffmpeg', '-i', src, '-vf', 'scale=-2:min(ih\,720)',
             '-c:v', 'libx264', '-crf', '28', '-preset', 'fast',
             '-c:a', 'aac', '-b:a', '128k', '-movflags', '+faststart',
             '-y', dst],
            capture_output=True, timeout=300
        )
        if result.returncode == 0 and os.path.exists(dst) and os.path.getsize(dst) <= max_bytes:
            return True
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    if os.path.exists(dst):
        os.remove(dst)
    return False


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
    iy_names = []
    for att in plugin["files"]:
        if att["is_plugin"]:
            n = re.sub(r'\.(iy|lua)$', '', att["filename"], flags=re.IGNORECASE)
            iy_names.append(n)
    if iy_names:
        return ", ".join(iy_names)
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
            async for message in channel.history(limit=None, oldest_first=False):
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
        if not any(att.filename.lower().endswith('.iy') or att.filename.lower().endswith('.lua') for att in message.attachments):
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
            "loadstring_urls": [],
        }

        for attachment in message.attachments:
            is_plugin = attachment.filename.lower().endswith('.iy') or attachment.filename.lower().endswith('.lua')
            
            filename = attachment.filename
            if is_plugin:
                filename = re.sub(r'\.lua$', '.iy', filename, flags=re.IGNORECASE)

            file_data = {
                "filename": filename,
                "url": f"plugins/{message.id}/{filename}",
                "size": attachment.size,
                "is_plugin": is_plugin,
            }
            
            plugin_dir = os.path.join(PLUGINS_DIR, str(message.id))
            filepath = os.path.join(plugin_dir, filename)
            
            MAX_FILE_SIZE = 25 * 1024 * 1024 # 25 MiB
            
            try:
                if attachment.size <= MAX_FILE_SIZE:
                    if not (os.path.exists(filepath) and os.path.getsize(filepath) == attachment.size):
                        os.makedirs(plugin_dir, exist_ok=True)
                        await attachment.save(filepath)
                elif attachment.filename.lower().endswith(VIDEO_EXTS):
                    if os.path.exists(filepath):
                        file_data["size"] = os.path.getsize(filepath)
                    else:
                        os.makedirs(plugin_dir, exist_ok=True)
                        tmp = filepath + '.tmp'
                        await attachment.save(tmp)
                        if compress_video(tmp, filepath, MAX_FILE_SIZE):
                            file_data["size"] = os.path.getsize(filepath)
                            print(f"Compressed {attachment.filename} ({attachment.size} -> {file_data['size']} bytes)")
                        else:
                            print(f"Could not compress {attachment.filename} under 25MB, using CDN.")
                            file_data["url"] = attachment.url
                        if os.path.exists(tmp):
                            os.remove(tmp)
                else:
                    print(f"Skipping local save for {attachment.filename} ({attachment.size} bytes) - exceeds 25MB limit.")
                    file_data["url"] = attachment.url
            except Exception as e:
                print(f"Failed to save {attachment.filename}: {e}")
                file_data["url"] = attachment.url
                
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


        plugin["name"] = extract_plugin_name(plugin)

        all_code = []
        for f in plugin["files"]:
            plugin_dir = os.path.join(PLUGINS_DIR, str(message.id))
            filepath = os.path.join(plugin_dir, f["filename"])
            if f.get("is_plugin") and f["size"] < 200_000 and os.path.exists(filepath):
                try:
                    with open(filepath, 'r', encoding='utf-8', errors='replace') as fh:
                        all_code.append(fh.read())
                except Exception:
                    pass
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
