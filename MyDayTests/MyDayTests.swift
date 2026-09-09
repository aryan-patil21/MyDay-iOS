//
//  MyDayTests.swift
//  MyDayTests
//
//  Created by Apple on 09/09/26.
//

import Testing
import Foundation
@testable import MyDay

struct MyDayTests {

    // MARK: - Habit Streak Engine Tests

    @Test func habitCurrentStreakWhenCompletedToday() async throws {
        let habit = Habit(title: "Morning Run")
        habit.toggleCompletionToday()
        
        #expect(habit.isCompletedToday == true)
        #expect(habit.currentStreak == 1)
    }
    
    @Test func habitCurrentStreakWhenCompletedYesterdayOnly() async throws {
        let calendar = Calendar.current
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: Date()))
        
        let habit = Habit(title: "Read Book", completedDates: [yesterday])
        
        #expect(habit.isCompletedToday == false)
        #expect(habit.currentStreak == 1)
    }
    
    @Test func habitCurrentStreakWhenMissedYesterdayResetsToZero() async throws {
        let calendar = Calendar.current
        let twoDaysAgo = try #require(calendar.date(byAdding: .day, value: -2, to: Date()))
        
        let habit = Habit(title: "Meditate", completedDates: [twoDaysAgo])
        
        #expect(habit.isCompletedToday == false)
        #expect(habit.currentStreak == 0)
    }
    
    @Test func habitCurrentStreakMultipleCheckInsSameDayCountsOnce() async throws {
        let calendar = Calendar.current
        let todayMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        let todayEvening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        
        let habit = Habit(title: "Drink Water", completedDates: [todayMorning, todayEvening])
        
        #expect(habit.currentStreak == 1)
    }

    // MARK: - NaturalLanguage Sentiment Analysis Tests

    @Test func sentimentAnalysisPositiveText() async throws {
        let positiveText = "I had a wonderful, highly productive day! Feeling deeply grateful and proud."
        let score = InsightsService.shared.analyzeSentiment(of: positiveText)
        
        #expect(score > 0.1)
    }

    @Test func sentimentAnalysisNegativeText() async throws {
        let negativeText = "Today was exhausting, frustrating, and everything felt completely overwhelming."
        let score = InsightsService.shared.analyzeSentiment(of: negativeText)
        
        #expect(score < -0.1)
    }

    @Test func sentimentAnalysisEmptyText() async throws {
        let emptyScore = InsightsService.shared.analyzeSentiment(of: "")
        let whitespaceScore = InsightsService.shared.analyzeSentiment(of: "   \n  ")
        
        #expect(emptyScore == 0.0)
        #expect(whitespaceScore == 0.0)
    }

    // MARK: - Habit Correlation Math Tests

    @Test func habitCorrelationWhenCompletedOnGreatDay() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let habit = Habit(title: "Meditation", completedDates: [today])
        let reflection = DailyReflection(date: today, mood: .great, entryText: "Felt very peaceful.")
        
        let correlations = InsightsService.shared.calculateHabitCorrelations(
            habits: [habit],
            reflections: [reflection]
        )
        
        let correlation = try #require(correlations.first)
        #expect(correlation.habitTitle == "Meditation")
        #expect(correlation.positiveDaysPercentage == 100)
    }
}
