//
//  DashboardView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \TaskItem.dueDate, order: .forward) private var tasks: [TaskItem]
    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]
    @Query(sort: \DailyReflection.date, order: .reverse) private var reflections: [DailyReflection]
    
    @State private var showingReflectionSheet = false
    @State private var showingNewTaskSheet = false
    
    // Computed Time-of-Day Greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<17: return "sun.max.fill"
        case 17..<21: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }
    
    private var greetingIconColor: Color {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<17: return .yellow
        case 17..<21: return .orange
        default: return .indigo
        }
    }
    
    private var todayReflection: DailyReflection? {
        reflections.first { Calendar.current.isDateInToday($0.date) }
    }
    
    private var completedHabitsCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    private var pendingFocusTasks: [TaskItem] {
        Array(tasks.filter { !$0.isCompleted }.prefix(3))
    }
    
    private var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private var totalDailyGoals: Int {
        habits.count + pendingFocusTasks.count + (todayReflection != nil ? 1 : 1)
    }
    
    private var completedDailyGoals: Int {
        completedHabitsCount + (todayReflection != nil ? 1 : 0)
    }
    
    private var dailyProgress: Double {
        guard totalDailyGoals > 0 else { return 0.0 }
        return Double(completedDailyGoals) / Double(totalDailyGoals)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // 1. Greeting Header
                    headerSection
                    
                    // 2. Daily Momentum Card
                    dailyMomentumCard
                    
                    // 3. Habits Quick Strip
                    habitsSection
                    
                    // 4. Focus Tasks Section
                    focusTasksSection
                    
                    // 5. Daily Reflection Card
                    reflectionSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingReflectionSheet) {
                NewReflectionSheet()
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskSheet()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(greeting)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
            
            Spacer()
            
            Image(systemName: greetingIcon)
                .font(.system(size: 30))
                .foregroundStyle(greetingIconColor)
                .padding(10)
                .background(greetingIconColor.opacity(0.15))
                .clipShape(Circle())
        }
    }
    
    private var dailyMomentumCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Momentum")
                        .font(.headline)
                    Text("\(completedDailyGoals) of \(totalDailyGoals) daily actions completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(Int(dailyProgress * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(.tint)
            }
            
            ProgressView(value: dailyProgress)
                .tint(.accentColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Habits")
                    .font(.title3.bold())
                Spacer()
                Text("\(completedHabitsCount)/\(habits.count) Done")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if habits.isEmpty {
                Text("No habits set yet. Head to the Habits tab to start your streak!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(habits) { habit in
                            habitCard(habit)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func habitCard(_ habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: habit.iconName)
                    .font(.body)
                    .foregroundStyle(habit.themeColor)
                    .frame(width: 32, height: 32)
                    .background(habit.themeColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        habit.toggleCompletionToday()
                    }
                } label: {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(habit.isCompletedToday ? habit.themeColor : .secondary)
                }
                .buttonStyle(.plain)
            }
            
            Text(habit.title)
                .font(.subheadline.bold())
                .lineLimit(1)
            
            Text("🔥 \(habit.currentStreak) day\(habit.currentStreak == 1 ? "" : "s")")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    private var focusTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Focus Tasks")
                    .font(.title3.bold())
                Spacer()
                Button {
                    showingNewTaskSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.subheadline.bold())
                }
            }
            
            if pendingFocusTasks.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("All focus tasks complete!")
                            .font(.subheadline.bold())
                        Text("Enjoy your day or add a new task.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(pendingFocusTasks) { task in
                        HStack(spacing: 12) {
                            Button {
                                withAnimation {
                                    task.isCompleted.toggle()
                                }
                            } label: {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title)
                                    .font(.subheadline.weight(.medium))
                                    .strikethrough(task.isCompleted, color: .secondary)
                                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                                
                                if !task.notes.isEmpty {
                                    Text(task.notes)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Text(task.priority.rawValue)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(priorityColor(for: task.priority).opacity(0.15))
                                .foregroundStyle(priorityColor(for: task.priority))
                                .clipShape(Capsule())
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                    }
                }
            }
        }
    }
    
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mindfulness & Mood")
                .font(.title3.bold())
            
            if let reflection = todayReflection {
                HStack(spacing: 12) {
                    Text(reflection.mood.emoji)
                        .font(.system(size: 36))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Feeling \(reflection.mood.rawValue)")
                                .font(.headline)
                                .foregroundStyle(reflection.mood.color)
                            
                            Spacer()
                            
                            Text(reflection.date.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if !reflection.entryText.isEmpty {
                            Text(reflection.entryText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "heart.text.square")
                        .font(.title)
                        .foregroundStyle(.purple)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("How was your day?")
                            .font(.headline)
                        Text("Check in to record your mood and gratitude.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Reflect") {
                        showingReflectionSheet = true
                    }
                    .font(.caption.bold())
                    .buttonStyle(.borderedProminent)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }
        }
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [TaskItem.self, Habit.self, DailyReflection.self], inMemory: true)
}
