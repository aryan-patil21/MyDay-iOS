//
//  AppDatabase.swift
//  MyDay
//
//  Created by Apple on 14/09/26.
//

import Foundation
import SwiftData

final class AppDatabase: @unchecked Sendable {
    static let shared = AppDatabase()
    
    let container: ModelContainer
    
    @MainActor
    var mainContext: ModelContext {
        container.mainContext
    }
    
    private init() {
        let schema = Schema([
            TaskItem.self,
            Habit.self,
            DailyReflection.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error)")
        }
    }
}
