//
//  TaskListView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.dueDate, order: .forward) private var tasks: [TaskItem]
    
    @State private var showingNewTaskSheet = false
    @State private var searchText = ""
    
    private var filteredTasks: [TaskItem] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var pendingTasks: [TaskItem] {
        filteredTasks.filter { !$0.isCompleted }
    }
    
    private var completedTasks: [TaskItem] {
        filteredTasks.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    emptyStateView
                } else {
                    List {
                        if !pendingTasks.isEmpty {
                            Section("Pending (\(pendingTasks.count))") {
                                ForEach(pendingTasks) { task in
                                    TaskRowView(task: task) {
                                        toggleTask(task)
                                    }
                                }
                                .onDelete(perform: deletePendingTasks)
                            }
                        }
                        
                        if !completedTasks.isEmpty {
                            Section("Completed (\(completedTasks.count))") {
                                ForEach(completedTasks) { task in
                                    TaskRowView(task: task) {
                                        toggleTask(task)
                                    }
                                }
                                .onDelete(perform: deleteCompletedTasks)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search tasks")
            .navigationTitle("Today's Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewTaskSheet = true
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskSheet()
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Tasks Yet", systemImage: "checklist")
        } description: {
            Text("Tap the + button to add your first task and start organizing your day.")
        } actions: {
            Button("Add Task") {
                showingNewTaskSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func toggleTask(_ task: TaskItem) {
        withAnimation {
            task.isCompleted.toggle()
            if task.isCompleted {
                NotificationManager.shared.cancelTaskReminder(for: task)
            }
        }
    }
    
    private func deletePendingTasks(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let task = pendingTasks[index]
                NotificationManager.shared.cancelTaskReminder(for: task)
                modelContext.delete(task)
            }
        }
    }
    
    private func deleteCompletedTasks(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let task = completedTasks[index]
                NotificationManager.shared.cancelTaskReminder(for: task)
                modelContext.delete(task)
            }
        }
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: TaskItem.self, inMemory: true)
}
