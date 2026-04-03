// BatteryManager.swift
// Reads battery status from IOKit Power Sources API

import Foundation
import IOKit.ps

class BatteryManager: ObservableObject {

    @Published var batteryLevel: Int = 100
    @Published var isCharging: Bool = false
    @Published var timeRemaining: String = "Calculating..."
    @Published var powerSource: String = "Unknown"
    @Published var hasBattery: Bool = true

    /// Reads current battery info from IOKit
    func updateBatteryInfo() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as [CFTypeRef]

        if sources.isEmpty {
            DispatchQueue.main.async { self.hasBattery = false }
            return
        }

        for source in sources {
            guard let info = IOPSGetPowerSourceDescription(snapshot, source)?
                .takeUnretainedValue() as? [String: Any] else { continue }

            DispatchQueue.main.async {
                // Battery level
                if let capacity = info[kIOPSCurrentCapacityKey as String] as? Int {
                    self.batteryLevel = capacity
                }

                // Charging state
                if let charging = info[kIOPSIsChargingKey as String] as? Bool {
                    self.isCharging = charging
                }

                // Power source type
                if let src = info[kIOPSPowerSourceStateKey as String] as? String {
                    self.powerSource = (src == kIOPSBatteryPowerValue as String)
                        ? "Battery" : "Power Adapter"
                }

                // Time remaining
                if let timeToEmpty = info[kIOPSTimeToEmptyKey as String] as? Int, timeToEmpty > 0 {
                    let h = timeToEmpty / 60
                    let m = timeToEmpty % 60
                    self.timeRemaining = "\(h)h \(m)m remaining"
                } else if let timeToFull = info[kIOPSTimeToFullChargeKey as String] as? Int, timeToFull > 0 {
                    let h = timeToFull / 60
                    let m = timeToFull % 60
                    self.timeRemaining = "\(h)h \(m)m to full"
                } else {
                    self.timeRemaining = self.isCharging ? "Calculating..." : "—"
                }
            }
        }
    }
}
