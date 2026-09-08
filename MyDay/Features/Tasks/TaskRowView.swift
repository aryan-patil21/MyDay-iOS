//
//  TaskRowView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    var onToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Label(task.dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                    
                    priorityBadge
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var isOverdue: Bool {
        !task.isCompleted && task.dueDate < Date()
    }
    
    @ViewBuilder
    private var priorityBadge: some View {
        Text(task.priority.rawValue)
            .font(.caption2.bold())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.15))
            .foregroundStyle(priorityColor)
            .clipShape(Capsule())
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}
