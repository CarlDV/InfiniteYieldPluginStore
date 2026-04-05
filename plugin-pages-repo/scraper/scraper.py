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
OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "plugins.json")


def extract_loadstring_urls(code):
    """Extract URLs from loadstring(game:HttpGet(...)) patterns.
    
    Returns a list of URL strings found inside loadstring calls.
    """
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


class PluginScraper(discord.Client):
    def __init__(self):
        super().__init__()
        self.plugins = []
        self.existing_plugins = {}
        self.load_existing_plugins()

    def load_existing_plugins(self):
        """Load existing plugins to reuse code and avoid rate limits."""
        if os.path.exists(OUTPUT_PATH):
            try:
                with open(OUTPUT_PATH, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    plugins_list = data.get("plugins", [])
                    for p in plugins_list:
                        if "id" in p:
                            self.existing_plugins[str(p["id"])] = p
                    print(f"Loaded {len(self.existing_plugins)} existing plugins for code reuse.")
            except Exception as e:
                print(f"Note: Could not load existing plugins. Starting fresh. ({e})")

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

            kwargs = {"limit": None, "oldest_first": True}

            message_count = 0
            new_plugins = 0
            async for message in channel.history(**kwargs):
                message_count += 1


                existing_plugin = self.existing_plugins.get(str(message.id))
                plugin_data = await self.parse_message(message, existing_plugin)
                
                if plugin_data:
                    self.plugins.append(plugin_data)
                    if not existing_plugin:
                        new_plugins += 1

                if message_count % 100 == 0:
                    print(f"  Processed {message_count} new messages, found {new_plugins} new plugins...")

            print(f"\nDone! Processed {message_count} new messages.")
            print(f"Added {new_plugins} new plugins. Total database size: {len(self.plugins)} plugins.")

            self.save_plugins()

        except discord.Forbidden:
            print("ERROR: No permission to access this channel.")
        except discord.NotFound:
            print("ERROR: Channel not found.")
        except Exception as e:
            print(f"ERROR: {e}")

        await self.close()

    async def parse_message(self, message, existing_plugin=None):
        """Parse a Discord message to extract plugin information."""
        if message.type != discord.MessageType.default and message.type != discord.MessageType.reply:
            return None

        if not message.attachments:
            return None

        has_iy = any(att.filename.lower().endswith('.iy') for att in message.attachments)
        if not has_iy:
            return None

        plugin = {
            "id": str(message.id),
            "message_url": message.jump_url,
            "author": {
                "name": message.author.display_name or message.author.name,
                "username": str(message.author),
                "avatar": str(message.author.display_avatar.url) if message.author.display_avatar else None,
            },
            "date": message.created_at.isoformat(),
            "content": message.content or "",
            "attachments": [],
            "code_blocks": [],
            "links": [],
            "embeds": [],
            "reactions": [],
        }

        for attachment in message.attachments:
            is_plugin = attachment.filename.lower().endswith('.iy')
            att_data = {
                "filename": attachment.filename,
                "url": attachment.url,
                "size": attachment.size,
                "is_plugin_file": is_plugin,
            }
            if is_plugin and not attachment.filename.lower().endswith('.rbxm') and attachment.size < 200_000:
                try:
                    existing_code = None
                    if existing_plugin:
                        for ext_att in existing_plugin.get("attachments", []):
                            if ext_att.get("filename") == attachment.filename and "code" in ext_att:
                                existing_code = ext_att["code"]
                                break
                                
                    if existing_code:
                        att_data["code"] = existing_code
                    else:
                        content_bytes = await attachment.read()
                        att_data["code"] = content_bytes.decode('utf-8', errors='replace')
                except Exception:
                    pass
            plugin["attachments"].append(att_data)

        code_block_pattern = r'```(?:lua)?\s*\n?(.*?)```'
        code_blocks = re.findall(code_block_pattern, message.content, re.DOTALL)
        plugin["code_blocks"] = [block.strip() for block in code_blocks]

        url_pattern = r'https?://[^\s<>\]\)\"\'`]+'
        urls = re.findall(url_pattern, message.content)
        plugin["links"] = urls

        for embed in message.embeds:
            emb_data = {
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
            if any([emb_data["title"], emb_data["description"], emb_data["image"], emb_data["thumbnail"]]):
                plugin["embeds"].append(emb_data)

        for reaction in message.reactions:
            plugin["reactions"].append({
                "emoji": str(reaction.emoji),
                "count": reaction.count,
            })

        plugin["name"] = self.extract_plugin_name(plugin)

        # --- Loadstring URL extraction ---
        all_code = []
        for att in plugin["attachments"]:
            if att.get("code"):
                all_code.append(att["code"])
        for cb in plugin["code_blocks"]:
            all_code.append(cb)

        combined_code = "\n".join(all_code)
        plugin["loadstring_urls"] = extract_loadstring_urls(combined_code)

        return plugin

    def extract_plugin_name(self, plugin):
        """Try to extract a meaningful name for the plugin."""
        for att in plugin["attachments"]:
            if att["is_plugin_file"]:
                name = att["filename"]
                name = re.sub(r'\.(iy)$', '', name, flags=re.IGNORECASE)
                return name

        if plugin["content"]:
            first_line = plugin["content"].split('\n')[0].strip()
            first_line = re.sub(r'[*_~`#]', '', first_line).strip()
            if first_line and len(first_line) < 100:
                return first_line

        if plugin["attachments"]:
            return plugin["attachments"][0]["filename"]

        return f"Plugin #{plugin['id'][-6:]}"

    def save_plugins(self):
        """Save collected plugins to JSON file and write .iy files locally."""
        os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

        # Save .iy files to plugins/ directory
        plugins_dir = os.path.join(os.path.dirname(OUTPUT_PATH), "..", "plugins")
        os.makedirs(plugins_dir, exist_ok=True)
        files_saved = 0

        for plugin in self.plugins:
            for att in plugin["attachments"]:
                if att.get("is_plugin_file") and att.get("code"):
                    # Save to plugins/<message_id>/<filename>
                    plugin_dir = os.path.join(plugins_dir, plugin["id"])
                    os.makedirs(plugin_dir, exist_ok=True)
                    file_path = os.path.join(plugin_dir, att["filename"])
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(att["code"])
                    # Update URL to local path
                    att["url"] = f"plugins/{plugin['id']}/{att['filename']}"
                    files_saved += 1

        print(f"Saved {files_saved} plugin files to {plugins_dir}")

        output = {
            "scraped_at": datetime.now(timezone.utc).isoformat(),
            "channel_id": str(CHANNEL_ID),
            "total_plugins": len(self.plugins),
            "plugins": self.plugins,
        }

        with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2, ensure_ascii=False)

        print(f"Saved {len(self.plugins)} plugins to {OUTPUT_PATH}")


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
