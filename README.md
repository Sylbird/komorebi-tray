# <img src="images/png/app.png" width="24"> Komorebi Tray

A tray app to manage komorebi tiling window manager for Windows.

- Show the current **workspace number** on tray icon.
- Show **workspace name** popup on workspace change.
- Start/Stop/Pause komorebi using the tray menu.
- Click on the tray icon to Pause/Resume komorebi.

Komorebi can be started, stopped and paused externally and the app will adjust accordingly: **it works independently from komorebi** and does not require any change to your current komorebi configuration (see [Quick start](#quick-start)).

If the app is already running but the connection with komorebi is lost, the app will wait for komorebi to start. If the app is started but komorebi has not been launched yet, the app will attempt to launch komorebi. This is useful if you want to use this app as a _launcher_ for Komorebi at Windows startup.

## Preview

https://github.com/user-attachments/assets/86e768b6-66a2-48ef-90d0-929fb263ed3f

## Quick start

Install Komorebi Tray using the latest [MSI Windows Installer](https://github.com/Sylbird/komorebi-tray/releases/latest).

Might need to add "komorebi-tray.exe" to komorebi ignore rule.

```json
"ignore_rules": [
    {
      "kind": "Exe",
      "id": "komorebi-tray.exe",
      "matching_strategy": "Equals"
    }
  ]
```

The main requirement is to set the `KOMOREBI_CONFIG_HOME` environment variable for your user, which is used to read the current komorebi configuration and for multiple AutoHotkey profile management.

```powershell
# Set KOMOREBI_CONFIG_HOME for the user
[System.Environment]::SetEnvironmentVariable("KOMOREBI_CONFIG_HOME", "$($Env:USERPROFILE)\.config\komorebi", "User")

# Check your current settings
[System.Environment]::GetEnvironmentVariable("KOMOREBI_CONFIG_HOME", "User")
```

For more information, see the official [Komorebi docs](https://lgug2z.github.io/komorebi/common-workflows/komorebi-config-home.html).
