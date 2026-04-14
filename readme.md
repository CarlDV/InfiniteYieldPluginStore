# Infinite Yield Plugin Store (Unofficial)

> [!NOTE]
> This is an unofficial community project and is not affiliated with the main Infinite Yield development team.

Welcome to the Infinite Yield Plugin Store, a centralized hub for browsing, creating, and installing community plugins for the Infinite Yield admin script.

---

### Key Features
- **Plugin Hub**: Browse over 100 community-made plugins with rich previews, search functionality, and author profiles.
- **[Plugin Maker](https://iyplugins.pages.dev/maker)**: A professional-grade visual IDE (powered by Monaco Editor) that allows you to create .iy plugins without writing boilerplate code.
- **Developer API**: Lightweight JSON endpoints designed for Luau integration, allowing for automated plugin loading and cataloging.
- **Discord Synchronization**: Plugin data is synchronized from the Infinite Yield Discord server to ensure the store is always up-to-date.

---

### Project Structure
- `/data`: Contains the plugins.json and api.json databases.
- `/plugins`: Stores the raw .iy plugin files synced from Discord.
- `/maker.js`: The core logic for the visual plugin generator.
- `/app.js`: The main store application and UI controller.

---

### Developer API
Developers can interact with the store catalog using the following endpoints:

- **Store Catalog (Lightweight)**: https://iyplugins.pages.dev/data/api.json
- **Full Database (Complete)**: https://iyplugins.pages.dev/data/plugins.json

Refer to the [API Documentation](https://iyplugins.pages.dev/api.html) for detailed response schemas and Luau examples.

---

### Contributing
Contributions to the Infinite Yield Plugin Store are welcome!

#### Adding Plugins
To add a plugin to the store, simply upload your `.iy` file to the appropriate channel in the **Infinite Yield Discord server**. The scraper will automatically detect new uploads. For immediate updates, you can mention **@dein2fl (david)** on the server.

#### Developing the Website
If you would like to improve the website UI, fix bugs, or add features:
1. Fork the repository.
2. Make your changes to the HTML, CSS, or JavaScript files.
3. Submit a Pull Request with a clear description of your improvements.

---

### Credits
This project is **80% vibecoded** using **Opus 4.6** and **Gemini 3.1 Pro**. Honestly, no one would want to code this manually xoxoxoxx.

---

### Links
- **Website**: [iyplugins.pages.dev](https://iyplugins.pages.dev/)
- **Plugin Maker**: [iyplugins.pages.dev/maker](https://iyplugins.pages.dev/maker)
- **Discord Support**: [Join IY Discord](https://discord.gg/78ZuWSq)

---
*Updates on the site run **when a new plugin has been uploaded (ran manually by me!)**, as specified in the GitHub Actions workflow file. If you uploaded a plugin to the Discord server, it will typically appear on the webpage within a day (or you can mention me on the IY server so I can update it immediately @dein2fl [david])*
