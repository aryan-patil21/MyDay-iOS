//
//  NotificationManager.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    private init() {
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    func updateAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = (settings.authorizationStatus == .authorized)
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleTaskReminder(for task: TaskItem) async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }
        guard task.dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(task.title)"
        if !task.notes.isEmpty {
            content.body = task.notes
        } else {
            content.body = "It's time to complete this task!"
        }
        content.sound = .default
        
        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: task.dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule task reminder: \(error)")
        }
    }
    
    func cancelTaskReminder(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task-\(task.id.uuidString)"])
    }
    
    func scheduleDailyReflectionReminder(at time: Date) async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Daily Reflection ✨"
        content.body = "How was your day? Take 60 seconds to log your mood and celebrate your wins."
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily-reflection-reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule daily reflection reminder: \(error)")
        }
    }
    
    func cancelDailyReflectionReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reflection-reminder"])
    }
}
