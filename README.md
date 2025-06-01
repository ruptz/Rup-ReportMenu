# 📋 Rup-ReportMenu
---

## ✨ Features

- 🎨 Modern, responsive UI with light/dark theme support
- 💬 Real-time chat between staff and players
- 🔍 Filtering and sorting options
- 🔐 Granular permission system
- ⚡ Performance optimized
- 📜 Transcripts for deleted reports
- 📡 Discord webhook logging
- 🎮 Player-friendly reporting interface
- 📊 Status tracking (Open, In Progress, Closed)
- 🚨 Priority levels (Low, Medium, High)

---

## 📥 Installation

1. Download the latest release from the [releases page](https://github.com/ruptz/Rup-ReportMenu/releases)
2. Extract the `Rup-ReportMenu` folder to your server's resources directory
3. Add `ensure Rup-ReportMenu` to your server.cfg
4. Configure the config.lua (see below)
5. Ensure you have [ox_lib](https://github.com/overextended/ox_lib) in your server
6. Restart your server

## ⚙️ Configuration

### 🔐 Permissions Setup

Add these permissions to your `server.cfg` or `permissions.cfg`:

```cfg
# Rup-ReportMenu
add_ace group.admin reportmenu.admin.view allow     # View all reports
add_ace group.admin reportmenu.admin.manage allow   # Manage status/priority
add_ace group.admin reportmenu.admin.delete allow   # Delete reports
add_ace group.mod reportmenu.mod.view allow         # View all reports
add_ace group.mod reportmenu.mod.manage allow       # Update status only
```

> ℹ️ **Note:**  
You can replace `group.admin` and `group.mod` with custom ACE groups or even a specific player’s license identifier.  
If you’re unfamiliar with ACE permissions, check out tutorials on the FiveM forums — or join my Discord and ask in `general-support`!

### ⏱️ Cooldown Settings

Edit `config.lua` to adjust cooldowns:
```lua
Config.Cooldowns = {
    Chat = 5000,     -- Chat message cooldown (ms)
    Report = 10000,  -- New report cooldown (ms)
    Theme = 10000    -- Theme switch cooldown (ms)
}
```

## 🎮 Usage

### Player Commands
- `/reports` - Open the report menu
- `/sendmessage` - Test messages being sent (Debug)
- `/createReport` - Test report creation (Debug)

### Staff Features
- Real-time report management
- Priority and status updates
- Chat with reporters
- Copy player identifiers
- Detailed report tracking

## 📜 Transcripts

### Automatic Transcript Generation
- When a report is deleted, a transcript of all messages is automatically generated.
- Transcripts are saved locally in the `transcripts/` folder.
- The transcript file is also attached to the Discord webhook for easy access.

### Transcript Format
- Includes report metadata (ID, title, reporter, status, priority).
- Contains all messages in chronological order.
- Supports media attachments with URLs.

## 📡 Discord Logging

### Webhook Integration
- All report actions (creation, deletion) are logged to Discord.
- Rich embeds provide detailed information about the report.
- Deleted reports include a transcript file attachment.

### Configuration
Edit `config.lua` to enable Discord logging:
```lua
Config.Discord = {
    Enabled = true, -- Set to true to enable Discord integration
    Webhook = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL', -- Replace with your actual webhook URL
    ImageUrl = 'https://i.imgur.com/OZyXBv0.png',
    CreateEmbedColor = 65280, -- Green
    ReportEmbedColor = 16711680 -- Red
}
```

> ℹ️ **Note:** Ensure your webhook URL is valid, read this if you dont know how to make a webhook [Guide](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)

### TODO
- Add teleporting to players etc

## 💡 Support

Found a bug or need help? 
- 🐛 [Create an issue](https://github.com/ruptz/Rup-ReportMenu/issues)
- 💬 [Join My Discord](https://discord.gg/PFwfnfUE6a)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
