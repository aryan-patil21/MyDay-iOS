//
//  SettingsSheet.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import UserNotifications

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderTime") private var dailyReminderTimeRaw: Double = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20
        components.minute = 0
        return (Calendar.current.date(from: components) ?? Date()).timeIntervalSince1970
    }()
    
    private var reminderDate: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: dailyReminderTimeRaw) },
            set: { dailyReminderTimeRaw = $0.timeIntervalSince1970 }
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications & Reminders") {
                    HStack {
                        Label("Notification Access", systemImage: "bell.badge.fill")
                        Spacer()
                        Text(notificationManager.isAuthorized ? "Enabled" : "Not Allowed")
                            .font(.subheadline)
                            .foregroundStyle(notificationManager.isAuthorized ? .green : .secondary)
                    }
                    
                    if !notificationManager.isAuthorized {
                        Button("Request Notification Permission") {
                            Task {
                                _ = await notificationManager.requestAuthorization()
                            }
                        }
                    }
                    
                    Toggle("Daily Evening Reflection", isOn: $dailyReminderEnabled)
                        .onChange(of: dailyReminderEnabled) { _, isEnabled in
                            Task {
                                if isEnabled {
                                    let granted = await notificationManager.requestAuthorization()
                                    if granted {
                                        await notificationManager.scheduleDailyReflectionReminder(at: reminderDate.wrappedValue)
                                    } else {
                                        dailyReminderEnabled = false
                                    }
                                } else {
                                    notificationManager.cancelDailyReflectionReminder()
                                }
                            }
                        }
                    
                    if dailyReminderEnabled {
                        DatePicker("Reminder Time", selection: reminderDate, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderDate.wrappedValue) { _, newTime in
                                Task {
                                    await notificationManager.scheduleDailyReflectionReminder(at: newTime)
                                }
                            }
                    }
                }
                
                Section("Privacy & Data") {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% Local & Private")
                                .font(.subheadline.bold())
                            Text("All tasks, habits, and reflections are stored exclusively on your device using SwiftData. No accounts, trackers, or cloud storage.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("About MyDay") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Native iOS)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Tech Stack")
                        Spacer()
                        Text("SwiftUI • SwiftData")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await notificationManager.updateAuthorizationStatus()
            }
        }
    }
}

#Preview {
    SettingsSheet()
}
