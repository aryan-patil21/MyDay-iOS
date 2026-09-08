//
//  NewTaskSheet.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct NewTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: Priority = .medium
    @State private var hasReminder: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("What needs to be done?", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Schedule & Priority") {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Remind Me on Due Date", isOn: $hasReminder)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newTask = TaskItem(
            title: trimmedTitle,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate,
            priority: priority
        )
        modelContext.insert(newTask)
        
        if hasReminder {
            Task {
                await NotificationManager.shared.scheduleTaskReminder(for: newTask)
            }
        }
        
        dismiss()
    }
}

#Preview {
    NewTaskSheet()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
