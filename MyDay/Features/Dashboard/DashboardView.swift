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
    @State private var showingSettingsSheet = false
    @State private var showingAnalyticsSheet = false
    @State private var showingStressBusters = false
    @State private var showingInsightsDetailSheet = false
    
    // MARK: - Color System
    
    private var accentColor: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.58, green: 0.65, blue: 0.88, alpha: 1.0)
                : UIColor(red: 0.28, green: 0.35, blue: 0.56, alpha: 1.0)
        })
    }
    
    // MARK: - Computed Properties
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    private var todayFormattedDate: String {
        Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
    
    private var totalTasksCount: Int {
        tasks.count
    }
    
    private var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private var totalHabitsCount: Int {
        habits.count
    }
    
    private var completedHabitsCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    private var remainingHabitsCount: Int {
        habits.filter { !$0.isCompletedToday }.count
    }
    
    private var todayReflection: DailyReflection? {
        reflections.first { Calendar.current.isDateInToday($0.date) }
    }
    
    private var previewTasks: [TaskItem] {
        let pending = tasks.filter { !$0.isCompleted }
        if pending.count >= 3 {
            return Array(pending.prefix(3))
        } else {
            let completed = tasks.filter { $0.isCompleted }
            let needed = 3 - pending.count
            return pending + Array(completed.prefix(needed))
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    // 1. Greeting & Date
                    headerSection
                    
                    sectionDivider
                    
                    // 2. Today Overview
                    todayOverviewSection
                    
                    // 3. AI Daily Insights Entry
                    aiInsightsEntrySection
                    
                    sectionDivider
                    
                    // 4. Today's Tasks
                    todayTasksSection
                    
                    sectionDivider
                    
                    // 5. Contextual Wellbeing
                    wellbeingSection
                    
                    sectionDivider
                    
                    // 6. Reflection
                    reflectionSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingAnalyticsSheet = true
                    } label: {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingReflectionSheet) {
                NewReflectionSheet()
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskSheet()
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsSheet()
            }
            .sheet(isPresented: $showingAnalyticsSheet) {
                NavigationStack {
                    AnalyticsTrendsView(tasks: tasks, habits: habits, reflections: reflections)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    showingAnalyticsSheet = false
                                }
                            }
                        }
                }
            }
            .sheet(isPresented: $showingStressBusters) {
                StressBustersView()
            }
            .sheet(isPresented: $showingInsightsDetailSheet) {
                InsightsDetailSheet(tasks: tasks, habits: habits, reflections: reflections)
            }
        }
    }
    
    // MARK: - Reusable Section Components
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .tracking(0.6)
    }
    
    private var sectionDivider: some View {
        Rectangle()
            .fill(Color(uiColor: .separator).opacity(0.4))
            .frame(height: 0.5)
    }
    
    // MARK: - 1. Greeting & Date
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.title.weight(.semibold))
                .foregroundStyle(.primary)
            
            Text(todayFormattedDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
    
    // MARK: - 2. Today Overview
    
    private var todayOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("TODAY")
            
            if totalTasksCount > 0 {
                let progressRatio = Double(completedTasksCount) / Double(totalTasksCount)
                let percentage = Int(progressRatio * 100)
                
                HStack(alignment: .firstTextBaseline) {
                    Text("\(completedTasksCount) of \(totalTasksCount) completed")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(percentage)%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                
                // Minimal editorial progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .tertiarySystemFill))
                            .frame(height: 3)
                        
                        Capsule()
                            .fill(accentColor)
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(progressRatio))), height: 3)
                    }
                }
                .frame(height: 3)
            } else {
                Text("No tasks scheduled for today")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            if totalHabitsCount > 0 {
                HStack(spacing: 6) {
                    Text(remainingHabitsCount == 0 ? "All habits completed" : "\(remainingHabitsCount) habit\(remainingHabitsCount == 1 ? "" : "s") remaining")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if remainingHabitsCount == 0 {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(uiColor: .systemGreen))
                    }
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - 3. AI Daily Insights Entry
    
    private var aiInsightsEntrySection: some View {
        Button {
            showingInsightsDetailSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 6) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(accentColor)
                    
                    Text("AI DAILY INSIGHTS")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.8)
                        .foregroundStyle(accentColor)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(accentColor.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your day, understood.")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Text("Discover patterns connecting your tasks, habits, and reflections.")
                        .font(.footnote)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    Text("Explore personalized insights")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(accentColor)
                .padding(.top, 2)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0.08),
                                Color.blue.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.18), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 4. Today's Tasks
    
    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("TASKS")
                
                Spacer()
                
                Button {
                    showingNewTaskSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if previewTasks.isEmpty {
                Text("No tasks for today.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(previewTasks) { task in
                        taskRow(task)
                    }
                }
            }
            
            NavigationLink {
                TaskListView()
            } label: {
                HStack(spacing: 4) {
                    Text("See all tasks")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(accentColor)
                .padding(.top, 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func taskRow(_ task: TaskItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    task.isCompleted.toggle()
                    if task.isCompleted {
                        NotificationManager.shared.cancelTaskReminder(for: task)
                    }
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(task.isCompleted ? Color(uiColor: .systemGreen) : Color(uiColor: .tertiaryLabel))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted, color: Color(uiColor: .tertiaryLabel))
                    .foregroundStyle(task.isCompleted ? Color(uiColor: .secondaryLabel) : Color(uiColor: .label))
                    .lineLimit(1)
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if task.priority == .high && !task.isCompleted {
                Text("High")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 4. Contextual Wellbeing
    
    private var wellbeingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader("TAKE A MOMENT")
            
            Text("Need a quick reset?")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("A short mental break can help restore your focus.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                showingStressBusters = true
            } label: {
                HStack(spacing: 4) {
                    Text("Try a breathing exercise")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(accentColor)
                .padding(.top, 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 5. Reflection
    
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("TODAY'S REFLECTION")
            
            if let reflection = todayReflection {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(reflection.mood.emoji)
                            .font(.body)
                        
                        Text("Feeling \(reflection.mood.rawValue)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(reflection.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    
                    if !reflection.entryText.isEmpty {
                        Text(reflection.entryText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    Button {
                        showingReflectionSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Update reflection")
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "arrow.right")
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(accentColor)
                        .padding(.top, 2)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("“What is one thing you're proud of today?”")
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Button {
                    showingReflectionSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Write a reflection")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "arrow.right")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(accentColor)
                    .padding(.top, 2)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [TaskItem.self, Habit.self, DailyReflection.self], inMemory: true)
}
