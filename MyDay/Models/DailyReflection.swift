//
//  DailyReflection.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import Foundation
import SwiftUI
import SwiftData

enum Mood: String, Codable, CaseIterable, Identifiable {
    case great = "Great"
    case good = "Good"
    case neutral = "Neutral"
    case down = "Down"
    case stressed = "Stressed"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good: return "🙂"
        case .neutral: return "😐"
        case .down: return "😔"
        case .stressed: return "😣"
        }
    }
    
    var color: Color {
        switch self {
        case .great: return .green
        case .good: return .teal
        case .neutral: return .blue
        case .down: return .orange
        case .stressed: return .purple
        }
    }
}

@Model
final class DailyReflection {
    var id: UUID
    var date: Date
    var mood: Mood
    var tags: [String]
    var entryText: String
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Mood = .good,
        tags: [String] = [],
        entryText: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.tags = tags
        self.entryText = entryText
        self.createdAt = createdAt
    }
}
