# BatteryGuard

BatteryGuard is a lightweight, native macOS menu bar app that monitors your battery percentage and alerts you when it drops below a configurable threshold. It runs entirely in the background (no Dock icon) and is built with **Swift**, **SwiftUI**, and the **IOKit** framework.

## Features

- **Menu Bar Presence:** Shows a clean battery icon and percentage in your status bar.
- **Animated Gauge:** Click the menu bar icon to reveal a beautiful, glassmorphic popover featuring a circular animated progress ring.
- **Smart Notifications:** Sends a native macOS notification (with an "OK" dismiss button) when your battery drops below the set threshold and is not charging.
- **Cooldown System:** Includes a 10-minute cooldown to prevent notification spam.
- **Sound Alerts:** Optionally plays the macOS "Glass" system sound alongside notifications.
- **Customizable Threshold:** Easily adjust the alert threshold (10%–50%) via a slider in the popover.
- **Dark Mode Support:** Fully adapts to macOS Light and Dark appearance.

## Requirements

- macOS 13.0 or later
- Swift 5

## Installation & Build Instructions

You can build and run this application directly from the source code without using Xcode.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/PraneshMithun-cse/Mac-battery_Guard.git
   cd Mac-battery_Guard
   ```

2. **Build the app:**
   A convenience shell script is provided to compile the Swift source files and bundle the app.
   ```bash
   # Make the script executable if it isn't already
   chmod +x build.sh
   # Run the script
   ./build.sh
   ```

3. **Run the app:**
   ```bash
   open build/BatteryGuard.app
   ```
   Or simply double-click the `BatteryGuard.app` file inside the `build` folder using Finder.

> **Tip:** If you'd like BatteryGuard to start automatically when you log in, go to **System Settings > General > Login Items** and add the `BatteryGuard.app`.

## Permissions

On its first run, BatteryGuard will request permission to send notifications. This is required for the low battery alerts to function properly.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.
