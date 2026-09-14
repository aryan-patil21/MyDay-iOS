//
//  MyDayShortcuts.swift
//  MyDay
//
//  Created by Apple on 14/09/26.
//

import AppIntents

struct MyDayShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetDailyMomentumIntent(),
            phrases: [
                "What's my \(.applicationName) momentum?",
                "Check \(.applicationName) momentum",
                "How is my \(.applicationName) looking?",
                "Check momentum in \(.applicationName)"
            ],
            shortTitle: "Check Momentum",
            systemImageName: "sun.max.fill"
        )
        
        AppShortcut(
            intent: CompleteHabitIntent(),
            phrases: [
                "Complete a habit in \(.applicationName)",
                "Check off habit in \(.applicationName)",
                "Log \(.applicationName) habit"
            ],
            shortTitle: "Complete Habit",
            systemImageName: "flame.fill"
        )
        
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add task to \(.applicationName)",
                "New task in \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "checklist"
        )
    }
}
