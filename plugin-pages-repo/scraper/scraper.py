import discord
import json
import os
import re
import asyncio
import random
import sys
import logging
from datetime import datetime, timezone

TOKEN = os.environ.get("DISCORD_TOKEN")
CHANNEL_ID = 551846012310782014
OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "plugins.json")


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

                await asyncio.sleep(random.uniform(0.3, 1.0))

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
                        await asyncio.sleep(random.uniform(0.5, 1.5))
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

        for reaction in message.reactions:
            plugin["reactions"].append({
                "emoji": str(reaction.emoji),
                "count": reaction.count,
            })

        plugin["name"] = self.extract_plugin_name(plugin)

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
        """Save collected plugins to JSON file."""
        os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

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
