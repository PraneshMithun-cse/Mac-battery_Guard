// BatteryGuard - macOS Menu Bar Battery Monitor
// Entry point for the application

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
