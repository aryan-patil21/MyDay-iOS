//
//  AddTaskIntent.swift
//  MyDay
//
//  Created by Apple on 14/09/26.
//

import AppIntents
import Foundation
import SwiftData

struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Task to MyDay"
    static var description = IntentDescription("Creates a new task in MyDay with a title and optional high priority.")
    
    @Parameter(title: "Task Title")
    var title: String
    
    @Parameter(title: "Is High Priority", default: false)
    var isHighPriority: Bool
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add '\(\.$title)' to MyDay") {
            \.$isHighPriority
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .result(
                value: "Failed",
                dialog: IntentDialog("Task title cannot be empty.")
            )
        }
        
        let context = AppDatabase.shared.mainContext
        let task = TaskItem(
            title: trimmed,
            dueDate: Date(),
            priority: isHighPriority ? .high : .medium
        )
        context.insert(task)
        try? context.save()
        
        let priorityNote = isHighPriority ? " as High Priority" : ""
        let dialogMessage = "Got it! Added '\(trimmed)'\(priorityNote) to your MyDay tasks."
        
        return .result(
            value: trimmed,
            dialog: IntentDialog(stringLiteral: dialogMessage)
        )
    }
}
