// NotificationManager.swift
// Handles macOS notification permissions, delivery, cooldown, and sound alerts

import Foundation
import UserNotifications
import AppKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    var isIgnored: Bool = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupCategories()
    }

    // MARK: - Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("⚠️ Notification permission error: \(error.localizedDescription)")
            }
            print(granted ? "✅ Notifications granted" : "❌ Notifications denied")
        }
    }

    // MARK: - Category with OK button
    private func setupCategories() {
        let ignoreAction = UNNotificationAction(
            identifier: "IGNORE_ACTION",
            title: "Ignore",
            options: [] // no special options needed
        )
        let category = UNNotificationCategory(
            identifier: "BATTERY_ALERT",
            actions: [ignoreAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Send Alert
    func sendBatteryAlert(level: Int) {
        if isIgnored { return }

        let content = UNMutableNotificationContent()
        content.title = "Battery Alert"
        content.body = "Battery is at \(level)%. Charge your Mac 🔋"
        content.categoryIdentifier = "BATTERY_ALERT"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "battery-alert",
            content: content,
            trigger: nil  // deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Failed to send notification: \(error.localizedDescription)")
            }
        }

        // Play system sound if enabled
        if UserDefaults.standard.bool(forKey: "soundEnabled") {
            NSSound(named: NSSound.Name("Glass"))?.play()
        }
    }

    // MARK: - Delegate: show notification even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // MARK: - Delegate: handle Ignore button tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "IGNORE_ACTION" {
            isIgnored = true
        }
        completionHandler()
    }
    
    // MARK: - Cancel Alert
    func cancelBatteryAlert() {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["battery-alert"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["battery-alert"])
    }
}
