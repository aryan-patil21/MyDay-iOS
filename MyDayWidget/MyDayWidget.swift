//
//  MyDayWidget.swift
//  MyDayWidget
//
//  Created by Apple on 10/09/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct MyDayWidgetEntry: TimelineEntry {
    let date: Date
    let greeting: String
    let momentumPercentage: Int
    let completedGoals: Int
    let totalGoals: Int
    let topHabitTitle: String
    let topHabitStreak: Int
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MyDayWidgetEntry {
        MyDayWidgetEntry(
            date: Date(),
            greeting: "Good morning",
            momentumPercentage: 75,
            completedGoals: 3,
            totalGoals: 4,
            topHabitTitle: "Morning Run",
            topHabitStreak: 5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MyDayWidgetEntry) -> Void) {
        let entry = MyDayWidgetEntry(
            date: Date(),
            greeting: "Today's Focus",
            momentumPercentage: 65,
            completedGoals: 2,
            totalGoals: 3,
            topHabitTitle: "Read 20 Mins",
            topHabitStreak: 4
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MyDayWidgetEntry>) -> Void) {
        let currentDate = Date()
        let hour = Calendar.current.component(.hour, from: currentDate)
        let greetingText: String
        switch hour {
        case 5..<12: greetingText = "Good morning"
        case 12..<17: greetingText = "Good afternoon"
        default: greetingText = "Good evening"
        }
        
        let entry = MyDayWidgetEntry(
            date: currentDate,
            greeting: greetingText,
            momentumPercentage: 80,
            completedGoals: 4,
            totalGoals: 5,
            topHabitTitle: "Workout",
            topHabitStreak: 7
        )

        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

// MARK: - Widget View

struct MyDayWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        default:
            mediumWidgetView
        }
    }

    // MARK: - Small Family View
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                Text(entry.greeting)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.momentumPercentage)%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Daily Momentum")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("\(entry.topHabitTitle) (🔥\(entry.topHabitStreak)d)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .containerBackground(for: .widget) {
            Color(uiColor: .systemBackground)
        }
    }

    // MARK: - Medium Family View
    private var mediumWidgetView: some View {
        HStack(spacing: 16) {
            // Left Column: Momentum & Greeting
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                    Text(entry.greeting)
                        .font(.subheadline.bold())
                }
                
                Spacer()
                
                Text("\(entry.momentumPercentage)%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("\(entry.completedGoals) of \(entry.totalGoals) daily actions met")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Right Column: Streak & Highlight
            VStack(alignment: .leading, spacing: 8) {
                Text("Top Habit Streak")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.topHabitTitle)
                            .font(.subheadline.bold())
                        Text("🔥 \(entry.topHabitStreak) consecutive days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Text("Keep building your daily momentum!")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .containerBackground(for: .widget) {
            Color(uiColor: .systemBackground)
        }
    }
}

// MARK: - Widget Definition

struct MyDayWidget: Widget {
    let kind: String = "MyDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MyDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MyDay Momentum")
        .description("Track your daily momentum and habit streaks directly from your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    MyDayWidget()
} timeline: {
    MyDayWidgetEntry(
        date: Date(),
        greeting: "Good morning",
        momentumPercentage: 75,
        completedGoals: 3,
        totalGoals: 4,
        topHabitTitle: "Morning Run",
        topHabitStreak: 5
    )
}

#Preview(as: .systemMedium) {
    MyDayWidget()
} timeline: {
    MyDayWidgetEntry(
        date: Date(),
        greeting: "Good morning",
        momentumPercentage: 75,
        completedGoals: 3,
        totalGoals: 4,
        topHabitTitle: "Morning Run",
        topHabitStreak: 5
    )
}
