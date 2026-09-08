//
//  ContentView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
            
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "flame.fill")
                }
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TaskItem.self, Habit.self, DailyReflection.self], inMemory: true)
}
