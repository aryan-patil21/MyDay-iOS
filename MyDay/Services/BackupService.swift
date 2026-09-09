//
//  BackupService.swift
//  MyDay
//
//  Created by Apple on 09/09/26.
//

import Foundation
import SwiftData

// MARK: - Codable Data Transfer Objects (DTOs)

struct TaskDTO: Codable {
    let id: UUID
    let title: String
    let notes: String
    let dueDate: Date
    let isCompleted: Bool
    let priority: String
    let createdAt: Date
}

struct HabitDTO: Codable {
    let id: UUID
    let title: String
    let iconName: String
    let colorName: String
    let completedDates: [Date]
    let createdAt: Date
}

struct ReflectionDTO: Codable {
    let id: UUID
    let date: Date
    let mood: String
    let tags: [String]
    let entryText: String
    let createdAt: Date
}

struct MyDayBackup: Codable {
    let exportedAt: Date
    let version: String
    let tasks: [TaskDTO]
    let habits: [HabitDTO]
    let reflections: [ReflectionDTO]
}

// MARK: - Backup Service

final class BackupService {
    static let shared = BackupService()
    
    private init() {}
    
    /// Generates a structured JSON backup file and returns its local temporary URL for sharing/exporting
    func generateBackupFile(
        tasks: [TaskItem],
        habits: [Habit],
        reflections: [DailyReflection]
    ) throws -> URL {
        let taskDTOs = tasks.map {
            TaskDTO(
                id: $0.id,
                title: $0.title,
                notes: $0.notes,
                dueDate: $0.dueDate,
                isCompleted: $0.isCompleted,
                priority: $0.priority.rawValue,
                createdAt: $0.createdAt
            )
        }
        
        let habitDTOs = habits.map {
            HabitDTO(
                id: $0.id,
                title: $0.title,
                iconName: $0.iconName,
                colorName: $0.colorName,
                completedDates: $0.completedDates,
                createdAt: $0.createdAt
            )
        }
        
        let reflectionDTOs = reflections.map {
            ReflectionDTO(
                id: $0.id,
                date: $0.date,
                mood: $0.mood.rawValue,
                tags: $0.tags,
                entryText: $0.entryText,
                createdAt: $0.createdAt
            )
        }
        
        let backup = MyDayBackup(
            exportedAt: Date(),
            version: "1.0.0",
            tasks: taskDTOs,
            habits: habitDTOs,
            reflections: reflectionDTOs
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(backup)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let filename = "MyDay_Backup_\(dateString).json"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: tempURL)
        return tempURL
    }
    
    /// Parses a JSON backup file and restores non-duplicate items into the SwiftData ModelContext
    func restoreBackup(
        from fileURL: URL,
        into context: ModelContext
    ) throws -> (tasks: Int, habits: Int, reflections: Int) {
        let shouldStopAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(MyDayBackup.self, from: data)
        
        // Fetch existing IDs to avoid duplicates
        let existingTasksDescriptor = FetchDescriptor<TaskItem>()
        let existingHabitsDescriptor = FetchDescriptor<Habit>()
        let existingReflectionsDescriptor = FetchDescriptor<DailyReflection>()
        
        let existingTaskIds = Set((try? context.fetch(existingTasksDescriptor).map { $0.id }) ?? [])
        let existingHabitIds = Set((try? context.fetch(existingHabitsDescriptor).map { $0.id }) ?? [])
        let existingReflectionIds = Set((try? context.fetch(existingReflectionsDescriptor).map { $0.id }) ?? [])
        
        var restoredTasks = 0
        var restoredHabits = 0
        var restoredReflections = 0
        
        // Restore Tasks
        for dto in backup.tasks where !existingTaskIds.contains(dto.id) {
            let priority = Priority(rawValue: dto.priority) ?? .medium
            let task = TaskItem(
                id: dto.id,
                title: dto.title,
                notes: dto.notes,
                dueDate: dto.dueDate,
                isCompleted: dto.isCompleted,
                priority: priority,
                createdAt: dto.createdAt
            )
            context.insert(task)
            restoredTasks += 1
        }
        
        // Restore Habits
        for dto in backup.habits where !existingHabitIds.contains(dto.id) {
            let habit = Habit(
                id: dto.id,
                title: dto.title,
                iconName: dto.iconName,
                colorName: dto.colorName,
                completedDates: dto.completedDates,
                createdAt: dto.createdAt
            )
            context.insert(habit)
            restoredHabits += 1
        }
        
        // Restore Reflections
        for dto in backup.reflections where !existingReflectionIds.contains(dto.id) {
            let mood = Mood(rawValue: dto.mood) ?? .good
            let reflection = DailyReflection(
                id: dto.id,
                date: dto.date,
                mood: mood,
                tags: dto.tags,
                entryText: dto.entryText,
                createdAt: dto.createdAt
            )
            context.insert(reflection)
            restoredReflections += 1
        }
        
        try context.save()
        return (restoredTasks, restoredHabits, restoredReflections)
    }
}
