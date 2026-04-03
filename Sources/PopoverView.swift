// PopoverView.swift
// Beautiful SwiftUI popover with glassmorphism, animated gauge, and settings

import SwiftUI

// MARK: - Main Popover View
struct PopoverView: View {
    @ObservedObject var batteryManager: BatteryManager
    var onQuit: () -> Void

    @AppStorage("batteryThreshold") private var threshold: Double = 30
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @State private var animateGlow: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──
            headerSection
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

            Divider().opacity(0.4)

            // ── Battery Gauge ──
            gaugeSection
                .padding(.vertical, 20)

            Divider().opacity(0.4)

            // ── Settings ──
            settingsSection
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            Divider().opacity(0.4)

            // ── Footer ──
            footerSection
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .frame(width: 320)
        .onAppear { animateGlow = true }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("BatteryGuard")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("Battery Monitor")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .shadow(color: statusColor.opacity(0.6), radius: 4)
                Text(batteryManager.isCharging ? "Charging" : "On Battery")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(Color.primary.opacity(0.06))
            )
        }
    }

    // MARK: - Battery Gauge
    private var gaugeSection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Glow layer
                Circle()
                    .trim(from: 0, to: CGFloat(batteryManager.batteryLevel) / 100.0)
                    .stroke(gaugeColor.opacity(0.25), style: StrokeStyle(lineWidth: 24, lineCap: .round))
                    .blur(radius: 10)
                    .rotationEffect(.degrees(-90))

                // Background track
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 14)

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(batteryManager.batteryLevel) / 100.0)
                    .stroke(gaugeColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: batteryManager.batteryLevel)

                // Center text
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(batteryManager.batteryLevel)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                        Text("%")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        if batteryManager.isCharging {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                        }
                        Text(batteryManager.timeRemaining)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 160, height: 160)

            // Power source badge
            HStack(spacing: 6) {
                Image(systemName: batteryManager.isCharging ? "powerplug.fill" : "leaf.fill")
                    .font(.system(size: 10))
                    .foregroundColor(batteryManager.isCharging ? .green : .orange)
                Text(batteryManager.powerSource)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color.primary.opacity(0.05))
            )
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 14) {
            // Threshold slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("Alert Threshold")
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                    Text("\(Int(threshold))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .monospacedDigit()
                }
                Slider(value: $threshold, in: 10...50, step: 5)
                    .controlSize(.small)
            }

            // Sound toggle
            HStack {
                Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 12))
                    .foregroundColor(soundEnabled ? .blue : .gray)
                Text("Sound Alert")
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Toggle("", isOn: $soundEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.04))
        )
    }

    // MARK: - Footer
    private var footerSection: some View {
        HStack {
            Text("v1.0")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.secondary.opacity(0.5))
            Spacer()
            Button(action: onQuit) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Quit")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }

    // MARK: - Computed Colors
    private var gaugeColor: Color {
        let level = batteryManager.batteryLevel
        if level > 60 { return Color(red: 0.2, green: 0.85, blue: 0.45) }
        if level > 30 { return Color(red: 1.0, green: 0.75, blue: 0.0) }
        return Color(red: 1.0, green: 0.3, blue: 0.3)
    }

    private var statusColor: Color {
        batteryManager.isCharging
            ? Color(red: 0.2, green: 0.85, blue: 0.45)
            : Color(red: 1.0, green: 0.75, blue: 0.0)
    }
}
