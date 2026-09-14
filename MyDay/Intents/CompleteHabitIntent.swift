//
//  CompleteHabitIntent.swift
//  MyDay
//
//  Created by Apple on 14/09/26.
//

import AppIntents
import Foundation
import SwiftData

struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete a Habit"
    static var description = IntentDescription("Marks a habit as completed for today and updates your streak.")
    
    @Parameter(title: "Habit")
    var habit: HabitEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("Complete \(\.$habit)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let context = AppDatabase.shared.mainContext
        let targetId = habit.id
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == targetId })
        
        guard let existingHabit = try? context.fetch(descriptor).first else {
            return .result(
                value: "Habit not found",
                dialog: IntentDialog("Could not find '\(habit.title)' in your habits.")
            )
        }
        
        if !existingHabit.isCompletedToday {
            existingHabit.toggleCompletionToday()
            try? context.save()
        }
        
        let streak = existingHabit.currentStreak
        let dialogMessage = "Awesome! Marked '\(existingHabit.title)' as done today. Your streak is now \(streak) \(streak == 1 ? "day" : "days")!"
        
        return .result(
            value: existingHabit.title,
            dialog: IntentDialog(stringLiteral: dialogMessage)
        )
    }
}
