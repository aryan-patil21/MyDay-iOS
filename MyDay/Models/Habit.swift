//
//  Habit.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Habit {
    var id: UUID
    var title: String
    var iconName: String
    var colorName: String
    var completedDates: [Date]
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        iconName: String = "flame.fill",
        colorName: String = "orange",
        completedDates: [Date] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.colorName = colorName
        self.completedDates = completedDates
        self.createdAt = createdAt
    }
    
    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completedDates.contains { calendar.isDateInToday($0) }
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let completedDays = Set(completedDates.map { calendar.startOfDay(for: $0) })
        
        var streak = 0
        var checkDate = today
        
        // If today is not checked off yet, check if the streak was active as of yesterday
        if !completedDays.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate),
                  completedDays.contains(yesterday) else {
                return 0
            }
            checkDate = yesterday
        }
        
        while completedDays.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        return streak
    }
    
    func toggleCompletionToday() {
        let calendar = Calendar.current
        if isCompletedToday {
            completedDates.removeAll { calendar.isDateInToday($0) }
        } else {
            completedDates.append(Date())
        }
    }
    
    var themeColor: Color {
        switch colorName.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .orange
        }
    }
}
