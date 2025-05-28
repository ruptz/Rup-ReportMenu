# 📋 Rup-ReportMenu
---

## ✨ Features

- 🎨 Modern, responsive UI with light/dark theme support
- 💬 Real-time chat between staff and players
- 🔍 Filtering and sorting options
- 🔐 Granular permission system
- ⚡ Performance optimized
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

## 💡 Support

Found a bug or need help? 
- 🐛 [Create an issue](https://github.com/ruptz/Rup-ReportMenu/issues)
- 💬 [Join My Discord](https://discord.gg/PFwfnfUE6a)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.