// AppDelegate.swift
// Manages the menu bar status item, popover, and orchestrates monitoring

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var monitorTimer: Timer?

    let batteryManager = BatteryManager()
    let notificationManager = NotificationManager()

    // MARK: - App Lifecycle
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register default settings
        UserDefaults.standard.register(defaults: [
            "batteryThreshold": 30,
            "soundEnabled": true
        ])

        // Hide dock icon — menu bar only
        NSApp.setActivationPolicy(.accessory)

        // Request notification permissions
        notificationManager.requestPermission()

        // Setup UI
        setupStatusItem()
        setupPopover()

        // Initial read
        batteryManager.updateBatteryInfo()
        updateStatusBarDisplay()

        // Periodic monitoring every 60 seconds
        monitorTimer = Timer.scheduledTimer(
            withTimeInterval: 60, repeats: true
        ) { [weak self] _ in
            self?.performPeriodicCheck()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitorTimer?.invalidate()
    }

    // MARK: - Setup
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    private func setupPopover() {
        let contentView = PopoverView(
            batteryManager: batteryManager,
            onQuit: { NSApplication.shared.terminate(nil) }
        )
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    // MARK: - Monitoring
    private func performPeriodicCheck() {
        batteryManager.updateBatteryInfo()
        updateStatusBarDisplay()
        checkBatteryAndNotify()
    }

    private func updateStatusBarDisplay() {
        guard let button = statusItem.button else { return }
        let level = batteryManager.batteryLevel
        let symbolName: String

        if batteryManager.isCharging {
            symbolName = "bolt.fill"
        } else if level > 75 {
            symbolName = "battery.100"
        } else if level > 50 {
            symbolName = "battery.75"
        } else if level > 25 {
            symbolName = "battery.50"
        } else {
            symbolName = "battery.25"
        }

        if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Battery") {
            let cfg = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            button.image = img.withSymbolConfiguration(cfg)
            button.title = " \(level)%"
        } else {
            button.image = nil
            button.title = "🔋 \(level)%"
        }
    }

    private func checkBatteryAndNotify() {
        guard batteryManager.hasBattery else { return }
        let threshold = UserDefaults.standard.integer(forKey: "batteryThreshold")
        if batteryManager.batteryLevel <= threshold && !batteryManager.isCharging {
            notificationManager.sendBatteryAlert(level: batteryManager.batteryLevel)
        }
    }

    // MARK: - Popover Toggle
    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            batteryManager.updateBatteryInfo()
            updateStatusBarDisplay()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
