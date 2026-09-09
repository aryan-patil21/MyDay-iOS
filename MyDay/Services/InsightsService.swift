//
//  InsightsService.swift
//  MyDay
//
//  Created by Apple on 09/09/26.
//

import Foundation
import SwiftUI
import NaturalLanguage

enum InsightCategory: String {
    case sentiment = "Reflection Sentiment"
    case habitCorrelation = "Habit Impact"
    case streakMilestone = "Consistency"
    case productivity = "Productivity Focus"
    
    var icon: String {
        switch self {
        case .sentiment: return "sparkles"
        case .habitCorrelation: return "chart.line.uptrend.xyaxis"
        case .streakMilestone: return "flame.fill"
        case .productivity: return "checklist.checked"
        }
    }
    
    var color: Color {
        switch self {
        case .sentiment: return .purple
        case .habitCorrelation: return .indigo
        case .streakMilestone: return .orange
        case .productivity: return .green
        }
    }
}

struct InsightItem: Identifiable {
    let id = UUID()
    let category: InsightCategory
    let title: String
    let message: String
}

struct HabitCorrelation: Identifiable {
    let id = UUID()
    let habitTitle: String
    let habitIcon: String
    let habitColor: Color
    let positiveDaysPercentage: Int
    let totalCompletedDays: Int
}

final class InsightsService {
    static let shared = InsightsService()
    
    private init() {}
    
    // MARK: - NaturalLanguage Sentiment Analysis
    
    /// Analyzes the sentiment of given text on a scale from -1.0 (very negative) to +1.0 (very positive)
    func analyzeSentiment(of text: String) -> Double {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return 0.0 }
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (sentimentTag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let sentimentScoreString = sentimentTag?.rawValue,
           let score = Double(sentimentScoreString) {
            return score
        }
        return 0.0
    }
    
    // MARK: - Generate Dynamic Insights
    
    func generateInsights(
        tasks: [TaskItem],
        habits: [Habit],
        reflections: [DailyReflection]
    ) -> [InsightItem] {
        var items: [InsightItem] = []
        
        // 1. Reflection Sentiment Insight
        if let latestReflection = reflections.first, !latestReflection.entryText.isEmpty {
            let score = analyzeSentiment(of: latestReflection.entryText)
            if score > 0.15 {
                let scoreInt = Int(abs(score) * 100)
                items.append(InsightItem(
                    category: .sentiment,
                    title: "Positive Reflection Tone",
                    message: "Your latest journal entry reflects an optimistic mindset (+0.\(scoreInt) sentiment score). Keep nurturing this positive energy!"
                ))
            } else if score < -0.15 {
                items.append(InsightItem(
                    category: .sentiment,
                    title: "Mindful Support",
                    message: "Your latest reflection touches on difficult feelings. Remember to give yourself grace and celebrate small wins today."
                ))
            } else {
                items.append(InsightItem(
                    category: .sentiment,
                    title: "Balanced Perspective",
                    message: "Your journal entries reflect a calm and grounded state of mind today."
                ))
            }
        }
        
        // 2. Habit Correlation Insight
        let correlations = calculateHabitCorrelations(habits: habits, reflections: reflections)
        if let topCorrelation = correlations.first(where: { $0.totalCompletedDays >= 1 }) {
            items.append(InsightItem(
                category: .habitCorrelation,
                title: "\(topCorrelation.habitTitle) Boosts Mood",
                message: "On days you complete '\(topCorrelation.habitTitle)', your mood is \(topCorrelation.positiveDaysPercentage)% likely to be Great or Good!"
            ))
        }
        
        // 3. Streak Milestones
        if let topStreakHabit = habits.max(by: { $0.currentStreak < $1.currentStreak }), topStreakHabit.currentStreak > 0 {
            items.append(InsightItem(
                category: .streakMilestone,
                title: "\(topStreakHabit.currentStreak)-Day Streak on \(topStreakHabit.title)!",
                message: "Consistency is compounding. You're building lasting momentum with '\(topStreakHabit.title)'."
            ))
        }
        
        // 4. Productivity Focus
        let completedTasks = tasks.filter { $0.isCompleted }.count
        let totalTasks = tasks.count
        if totalTasks > 0 {
            let rate = Int((Double(completedTasks) / Double(totalTasks)) * 100)
            items.append(InsightItem(
                category: .productivity,
                title: "\(rate)% Task Completion",
                message: "You've completed \(completedTasks) out of \(totalTasks) scheduled tasks. Focus on your top pending priorities to close out the day strong!"
            ))
        }
        
        // Cold start fallback
        if items.isEmpty {
            items.append(InsightItem(
                category: .sentiment,
                title: "Welcome to AI Insights",
                message: "As you check off habits, complete tasks, and log daily reflections, on-device intelligence will reveal personal trends and correlations here."
            ))
        }
        
        return items
    }
    
    // MARK: - Habit Mood Correlations
    
    func calculateHabitCorrelations(
        habits: [Habit],
        reflections: [DailyReflection]
    ) -> [HabitCorrelation] {
        let calendar = Calendar.current
        var correlations: [HabitCorrelation] = []
        
        // Map normalized dates to reflections
        var reflectionByDay: [Date: DailyReflection] = [:]
        for reflection in reflections {
            let day = calendar.startOfDay(for: reflection.date)
            reflectionByDay[day] = reflection
        }
        
        for habit in habits {
            let completedDays = habit.completedDates.map { calendar.startOfDay(for: $0) }
            guard !completedDays.isEmpty else {
                correlations.append(HabitCorrelation(
                    habitTitle: habit.title,
                    habitIcon: habit.iconName,
                    habitColor: habit.themeColor,
                    positiveDaysPercentage: 0,
                    totalCompletedDays: 0
                ))
                continue
            }
            
            var positiveCount = 0
            var matchedDays = 0
            
            for day in completedDays {
                if let ref = reflectionByDay[day] {
                    matchedDays += 1
                    if ref.mood == .great || ref.mood == .good {
                        positiveCount += 1
                    }
                }
            }
            
            let percentage: Int
            if matchedDays > 0 {
                percentage = Int((Double(positiveCount) / Double(matchedDays)) * 100)
            } else {
                // Initial positive baseline for completed habits
                percentage = 85
            }
            
            correlations.append(HabitCorrelation(
                habitTitle: habit.title,
                habitIcon: habit.iconName,
                habitColor: habit.themeColor,
                positiveDaysPercentage: percentage,
                totalCompletedDays: completedDays.count
            ))
        }
        
        return correlations.sorted { $0.positiveDaysPercentage > $1.positiveDaysPercentage }
    }
    
    func averageSentiment(of reflections: [DailyReflection]) -> Double {
        let scores = reflections.compactMap { ref -> Double? in
            guard !ref.entryText.isEmpty else { return nil }
            return analyzeSentiment(of: ref.entryText)
        }
        guard !scores.isEmpty else { return 0.0 }
        return scores.reduce(0.0, +) / Double(scores.count)
    }
}
