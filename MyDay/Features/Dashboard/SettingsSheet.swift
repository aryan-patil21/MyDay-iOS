//
//  SettingsSheet.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData
import UserNotifications
import UniformTypeIdentifiers

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var tasks: [TaskItem]
    @Query private var habits: [Habit]
    @Query private var reflections: [DailyReflection]
    
    @StateObject private var notificationManager = NotificationManager.shared
    
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("dailyReminderTime") private var dailyReminderTimeRaw: Double = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20
        components.minute = 0
        return (Calendar.current.date(from: components) ?? Date()).timeIntervalSince1970
    }()
    
    @State private var showingImporter = false
    @State private var exportURL: URL? = nil
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    private var reminderDate: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: dailyReminderTimeRaw) },
            set: { dailyReminderTimeRaw = $0.timeIntervalSince1970 }
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Notifications
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
                
                // Section 2: Data Backup & Portability
                Section("Data Backup & Portability") {
                    if let url = exportURL {
                        ShareLink(item: url) {
                            Label("Share Exported Backup (.json)", systemImage: "square.and.arrow.up.fill")
                                .foregroundStyle(.tint)
                        }
                    } else {
                        Button {
                            prepareBackup()
                        } label: {
                            Label("Export Data to JSON", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import Data from JSON", systemImage: "square.and.arrow.down")
                    }
                    
                    Text("Your backup contains \(tasks.count) tasks, \(habits.count) habits, and \(reflections.count) reflections.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Section 3: Privacy Guarantee
                Section("Privacy & Local Storage") {
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
                
                // Section 4: About
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
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .task {
                await notificationManager.updateAuthorizationStatus()
            }
        }
    }
    
    private func prepareBackup() {
        do {
            let url = try BackupService.shared.generateBackupFile(
                tasks: tasks,
                habits: habits,
                reflections: reflections
            )
            exportURL = url
        } catch {
            alertTitle = "Export Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        do {
            guard let selectedURL = try result.get().first else { return }
            let counts = try BackupService.shared.restoreBackup(from: selectedURL, into: modelContext)
            
            alertTitle = "Import Successful! 🎉"
            alertMessage = "Restored \(counts.tasks) tasks, \(counts.habits) habits, and \(counts.reflections) reflections."
            showingAlert = true
        } catch {
            alertTitle = "Import Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

#Preview {
    SettingsSheet()
}
