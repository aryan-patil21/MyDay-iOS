//
//  GetDailyMomentumIntent.swift
//  MyDay
//
//  Created by Apple on 14/09/26.
//

import AppIntents
import Foundation
import SwiftData

struct GetDailyMomentumIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Daily Momentum"
    static var description = IntentDescription("Reads back your daily momentum percentage, habits completed, and pending focus tasks.")
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<Int> {
        let context = AppDatabase.shared.mainContext
        
        let habits = (try? context.fetch(FetchDescriptor<Habit>())) ?? []
        let tasks = (try? context.fetch(FetchDescriptor<TaskItem>())) ?? []
        let reflections = (try? context.fetch(FetchDescriptor<DailyReflection>())) ?? []
        
        let completedHabits = habits.filter { $0.isCompletedToday }.count
        let totalHabits = habits.count
        
        let calendar = Calendar.current
        let todayTasks = tasks.filter { calendar.isDateInToday($0.dueDate) }
        let pendingTasks = todayTasks.filter { !$0.isCompleted }.count
        let completedTasks = todayTasks.filter { $0.isCompleted }.count
        
        let hasReflected = reflections.contains { calendar.isDateInToday($0.date) }
        
        let totalActions = totalHabits + (todayTasks.isEmpty ? tasks.filter { !$0.isCompleted }.count : todayTasks.count) + 1
        let completedActions = completedHabits + completedTasks + (hasReflected ? 1 : 0)
        
        let momentumPercentage: Int
        if totalActions > 0 {
            momentumPercentage = min(100, Int((Double(completedActions) / Double(totalActions)) * 100))
        } else {
            momentumPercentage = 0
        }
        
        let dialogMessage: String
        if momentumPercentage >= 100 {
            dialogMessage = "Sensational! Your daily momentum is at 100%! All habits and focus tasks for today are complete!"
        } else if momentumPercentage > 0 {
            dialogMessage = "Your daily momentum is at \(momentumPercentage)%. You've completed \(completedHabits) of \(totalHabits) habits with \(pendingTasks) pending focus tasks remaining. Keep going!"
        } else {
            dialogMessage = "Your day is just getting started with 0% momentum. Check off your first habit or task to kick off your streak!"
        }
        
        return .result(
            value: momentumPercentage,
            dialog: IntentDialog(stringLiteral: dialogMessage)
        )
    }
}
