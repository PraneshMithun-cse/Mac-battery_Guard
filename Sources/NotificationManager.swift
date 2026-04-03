// NotificationManager.swift
// Handles macOS notification permissions, delivery, cooldown, and sound alerts

import Foundation
import UserNotifications
import AppKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    private var lastNotificationTime: Date?
    private let cooldownSeconds: TimeInterval = 600  // 10 minutes

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
        let okAction = UNNotificationAction(
            identifier: "OK_ACTION",
            title: "OK",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: "BATTERY_ALERT",
            actions: [okAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Send Alert
    func sendBatteryAlert(level: Int) {
        // Enforce 10-minute cooldown
        if let last = lastNotificationTime,
           Date().timeIntervalSince(last) < cooldownSeconds {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Battery Alert"
        content.body = "Charge your Mac 🔋"
        content.categoryIdentifier = "BATTERY_ALERT"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "battery-alert-\(UUID().uuidString)",
            content: content,
            trigger: nil  // deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Failed to send notification: \(error.localizedDescription)")
            }
        }

        lastNotificationTime = Date()

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

    // MARK: - Delegate: handle OK button tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Notification dismissed (OK tapped or clicked)
        completionHandler()
    }
}
