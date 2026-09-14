//
//  HabitEntity.swift
//  MyDay
//
//  Created by Apple on 14/09/26.
//

import AppIntents
import Foundation
import SwiftData

struct HabitEntity: AppEntity {
    static var defaultQuery = HabitQuery()
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(currentStreak) day streak"
        )
    }
    
    let id: UUID
    
    @Property(title: "Title")
    var title: String
    
    @Property(title: "Current Streak")
    var currentStreak: Int
    
    init(id: UUID, title: String, currentStreak: Int) {
        self.id = id
        self.title = title
        self.currentStreak = currentStreak
    }
    
    init(from habit: Habit) {
        self.id = habit.id
        self.title = habit.title
        self.currentStreak = habit.currentStreak
    }
}

struct HabitQuery: EntityQuery, EnumerableEntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [HabitEntity] {
        let context = AppDatabase.shared.mainContext
        let descriptor = FetchDescriptor<Habit>()
        let habits = (try? context.fetch(descriptor)) ?? []
        let idSet = Set(identifiers)
        return habits.filter { idSet.contains($0.id) }.map { HabitEntity(from: $0) }
    }
    
    @MainActor
    func allEntities() async throws -> [HabitEntity] {
        let context = AppDatabase.shared.mainContext
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.title)])
        let habits = (try? context.fetch(descriptor)) ?? []
        return habits.map { HabitEntity(from: $0) }
    }
    
    @MainActor
    func suggestedEntities() async throws -> [HabitEntity] {
        try await allEntities()
    }
}
