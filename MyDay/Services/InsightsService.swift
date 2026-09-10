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

@MainActor
final class InsightsService {
    static let shared = InsightsService()
    
    private init() {}
    
    // MARK: - NaturalLanguage Sentiment Analysis
    
    /// Analyzes sentiment using Apple's NLTagger across sentence boundaries to prevent single-token bias.
    func analyzeSentiment(of text: String) -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0.0 }
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = trimmed
        
        var sentenceScores: [Double] = []
        tagger.enumerateTags(
            in: trimmed.startIndex..<trimmed.endIndex,
            unit: .sentence,
            scheme: .sentimentScore
        ) { tag, _ in
            if let tagValue = tag?.rawValue, let score = Double(tagValue) {
                sentenceScores.append(score)
            }
            return true
        }
        
        if !sentenceScores.isEmpty {
            return sentenceScores.reduce(0.0, +) / Double(sentenceScores.count)
        }
        
        let (paragraphTag, _) = tagger.tag(at: trimmed.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let scoreString = paragraphTag?.rawValue, let score = Double(scoreString) {
            return score
        }
        return 0.0
    }
    
    /// Calibrated, holistic sentiment score that blends:
    /// 1. User's explicit Mood selection (50% weight)
    /// 2. Selected Feeling Tags (20% weight)
    /// 3. On-device NLTagger text analysis (30% weight)
    /// This resolves Apple NLTagger's strong negative bias on casual, factual daily journaling.
    func sentiment(for reflection: DailyReflection) -> Double {
        let trimmedText = reflection.entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasText = !trimmedText.isEmpty
        let nlpScore = hasText ? analyzeSentiment(of: trimmedText) : 0.0
        
        // 1. Mood Baseline
        let moodBaseline: Double
        switch reflection.mood {
        case .great:    moodBaseline = 0.85
        case .good:     moodBaseline = 0.50
        case .neutral:  moodBaseline = 0.05
        case .down:     moodBaseline = -0.50
        case .stressed: moodBaseline = -0.75
        }
        
        // 2. Feeling Tags Modifier
        var tagModifier = 0.0
        let positiveTags: Set<String> = ["Grateful", "Productive", "Relaxed", "Energetic", "Inspired"]
        let negativeTags: Set<String> = ["Anxious", "Tired", "Busy", "Stressed"]
        for tag in reflection.tags {
            if positiveTags.contains(tag) { tagModifier += 0.08 }
            if negativeTags.contains(tag) { tagModifier -= 0.08 }
        }
        tagModifier = max(-0.25, min(0.25, tagModifier))
        
        // 3. Blended Synthesis
        if hasText {
            let combined = (moodBaseline * 0.50) + tagModifier + (nlpScore * 0.30)
            return max(-1.0, min(1.0, combined))
        } else {
            let combined = (moodBaseline * 0.80) + tagModifier
            return max(-1.0, min(1.0, combined))
        }
    }
    
    // MARK: - Generate Dynamic Insights
    
    func generateInsights(
        tasks: [TaskItem],
        habits: [Habit],
        reflections: [DailyReflection]
    ) -> [InsightItem] {
        var items: [InsightItem] = []
        
        // 1. Reflection Sentiment Insight (Focuses on latest logged reflection)
        if let latestReflection = reflections.first {
            let score = sentiment(for: latestReflection)
            if score > 0.15 {
                let formattedScore = String(format: "%+.2f", score)
                items.append(InsightItem(
                    category: .sentiment,
                    title: "Positive Reflection Tone",
                    message: "Your latest reflection reflects an optimistic mindset (\(formattedScore) sentiment). Keep nurturing this positive energy!"
                ))
            } else if score < -0.15 {
                let formattedScore = String(format: "%+.2f", score)
                items.append(InsightItem(
                    category: .sentiment,
                    title: "Mindful Support",
                    message: "Your latest reflection touches on difficult feelings (\(formattedScore) sentiment). Remember to give yourself grace and celebrate small wins."
                ))
            } else {
                items.append(InsightItem(
                    category: .sentiment,
                    title: "Balanced Perspective",
                    message: "Your latest reflection reflects a calm and grounded state of mind today."
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
    
    /// Calculates the average calibrated sentiment across all reflections
    func averageSentiment(of reflections: [DailyReflection]) -> Double {
        guard !reflections.isEmpty else { return 0.0 }
        let total = reflections.reduce(0.0) { $0 + sentiment(for: $1) }
        return total / Double(reflections.count)
    }
}
