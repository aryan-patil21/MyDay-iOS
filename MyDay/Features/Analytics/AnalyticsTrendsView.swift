//
//  AnalyticsTrendsView.swift
//  MyDay
//
//  Created by Apple on 19/09/26.
//

import SwiftUI
import Charts
import SwiftData

struct SentimentDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let mood: Mood
}

struct WeekdayHabitDataPoint: Identifiable {
    let id = UUID()
    let weekday: String
    let weekdayIndex: Int
    let count: Int
}

struct PriorityTaskDataPoint: Identifiable {
    let id = UUID()
    let priority: Priority
    let count: Int
}

struct AnalyticsTrendsView: View {
    let tasks: [TaskItem]
    let habits: [Habit]
    let reflections: [DailyReflection]
    
    @State private var selectedTimeRange: Int = 7 // 7 or 30 days
    @State private var selectedSentimentPoint: SentimentDataPoint? = nil
    
    // MARK: - Processed Chart Data
    
    private var filteredReflections: [DailyReflection] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -selectedTimeRange, to: Date()) ?? Date()
        return reflections
            .filter { $0.date >= cutoff }
            .sorted { $0.date < $1.date }
    }
    
    private var sentimentTrajectory: [SentimentDataPoint] {
        filteredReflections.map { ref in
            let score = InsightsService.shared.sentiment(for: ref)
            return SentimentDataPoint(date: ref.date, score: score, mood: ref.mood)
        }
    }
    
    private var habitWeekdayData: [WeekdayHabitDataPoint] {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -selectedTimeRange, to: Date()) ?? Date()
        
        let weekdaySymbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var counts = [Int](repeating: 0, count: 7)
        
        for habit in habits {
            for completedDate in habit.completedDates where completedDate >= cutoff {
                // Calendar weekday: 1 = Sunday, 2 = Monday, ... 7 = Saturday
                let weekday = calendar.component(.weekday, from: completedDate)
                let adjustedIndex = (weekday + 5) % 7 // Maps Monday to 0, Sunday to 6
                counts[adjustedIndex] += 1
            }
        }
        
        return (0..<7).map { index in
            WeekdayHabitDataPoint(
                weekday: weekdaySymbols[index],
                weekdayIndex: index,
                count: counts[index]
            )
        }
    }
    
    private var taskPriorityData: [PriorityTaskDataPoint] {
        let completedTasks = tasks.filter { $0.isCompleted }
        let highCount = completedTasks.filter { $0.priority == .high }.count
        let mediumCount = completedTasks.filter { $0.priority == .medium }.count
        let lowCount = completedTasks.filter { $0.priority == .low }.count
        
        var points: [PriorityTaskDataPoint] = []
        if highCount > 0 { points.append(PriorityTaskDataPoint(priority: .high, count: highCount)) }
        if mediumCount > 0 { points.append(PriorityTaskDataPoint(priority: .medium, count: mediumCount)) }
        if lowCount > 0 { points.append(PriorityTaskDataPoint(priority: .low, count: lowCount)) }
        
        return points
    }
    
    private var overallCompletionRate: Int {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.isCompleted }.count
        return Int((Double(completed) / Double(tasks.count)) * 100)
    }
    
    // MARK: - View Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Range Segmented Picker
                Picker("Time Window", selection: $selectedTimeRange) {
                    Text("Past 7 Days").tag(7)
                    Text("Past 30 Days").tag(30)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Chart 1: Sentiment Valence Trajectory Curve
                sentimentTrajectorySection
                
                // Chart 2: Habit Consistency by Weekday
                habitConsistencySection
                
                // Chart 3: Task Priority Distribution Donut
                taskVelocitySection
            }
            .padding(.vertical)
        }
        .navigationTitle("Visual Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    // MARK: - Subviews
    
    private var sentimentTrajectorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Emotional Trajectory")
                        .font(.headline)
                    Text("Daily on-device sentiment scores (-1.0 to +1.0)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let selected = selectedSentimentPoint {
                    HStack(spacing: 4) {
                        Text(selected.mood.emoji)
                        Text(String(format: "%+.2f", selected.score))
                            .font(.caption.bold())
                            .foregroundStyle(scoreColor(for: selected.score))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(scoreColor(for: selected.score).opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            
            if sentimentTrajectory.isEmpty {
                emptyStateView(message: "Log reflections in the Journal tab to visualize your emotional trajectory.")
            } else {
                Chart {
                    // Zero-line neutral threshold
                    RuleMark(y: .value("Neutral Baseline", 0.0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.secondary.opacity(0.5))
                    
                    // Smooth gradient area fill
                    ForEach(sentimentTrajectory) { point in
                        AreaMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Sentiment", point.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.35), Color.blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        LineMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Sentiment", point.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .foregroundStyle(Color.purple)
                        
                        PointMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Sentiment", point.score)
                        )
                        .foregroundStyle(scoreColor(for: point.score))
                        .symbolSize(40)
                    }
                }
                .chartYScale(domain: -1.0...1.0)
                .chartYAxis {
                    AxisMarks(values: [-1.0, -0.5, 0.0, 0.5, 1.0]) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(String(format: "%+.1f", doubleValue))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: selectedTimeRange == 7 ? 1 : 5)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var habitConsistencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Habit Consistency by Weekday")
                    .font(.headline)
                Text("Total habit check-ins across the selected time range")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            let totalCompletions = habitWeekdayData.reduce(0) { $0 + $1.count }
            if totalCompletions == 0 {
                emptyStateView(message: "Check off habits to identify your most consistent weekdays.")
            } else {
                Chart(habitWeekdayData) { point in
                    BarMark(
                        x: .value("Day", point.weekday),
                        y: .value("Completions", point.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.indigo, Color.purple],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 180)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var taskVelocitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Completed Tasks by Priority")
                    .font(.headline)
                Text("Distribution of executed focus items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if taskPriorityData.isEmpty {
                emptyStateView(message: "Complete scheduled tasks to view your priority execution balance.")
            } else {
                HStack(spacing: 20) {
                    Chart(taskPriorityData) { point in
                        SectorMark(
                            angle: .value("Tasks", point.count),
                            innerRadius: .ratio(0.65),
                            angularInset: 2.0
                        )
                        .foregroundStyle(priorityColor(for: point.priority))
                        .cornerRadius(4)
                    }
                    .frame(height: 160)
                    .overlay {
                        VStack(spacing: 2) {
                            Text("\(overallCompletionRate)%")
                                .font(.title3.bold())
                            Text("Completed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(taskPriorityData) { point in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(priorityColor(for: point.priority))
                                    .frame(width: 10, height: 10)
                                Text(point.priority.rawValue)
                                    .font(.caption.bold())
                                Spacer()
                                Text("\(point.count) tasks")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private func emptyStateView(message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
    
    private func scoreColor(for score: Double) -> Color {
        if score > 0.15 { return .green }
        if score < -0.15 { return .orange }
        return .blue
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .blue
        case .low: return .secondary
        }
    }
}

#Preview {
    NavigationStack {
        AnalyticsTrendsView(tasks: [], habits: [], reflections: [])
    }
}
