//
//  InsightsDetailSheet.swift
//  MyDay
//
//  Created by Apple on 09/09/26.
//

import SwiftUI

struct InsightsDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let tasks: [TaskItem]
    let habits: [Habit]
    let reflections: [DailyReflection]
    
    private var insights: [InsightItem] {
        InsightsService.shared.generateInsights(tasks: tasks, habits: habits, reflections: reflections)
    }
    
    private var correlations: [HabitCorrelation] {
        InsightsService.shared.calculateHabitCorrelations(habits: habits, reflections: reflections)
    }
    
    private var latestReflection: DailyReflection? {
        reflections.first
    }
    
    private var latestSentiment: Double {
        guard let latest = latestReflection else { return 0.0 }
        return InsightsService.shared.sentiment(for: latest)
    }
    
    private var avgSentiment: Double {
        InsightsService.shared.averageSentiment(of: reflections)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Section 1: AI Generated Summary Cards
                Section("Smart Insights (\(insights.count))") {
                    ForEach(insights) { insight in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: insight.category.icon)
                                .font(.body)
                                .foregroundStyle(insight.category.color)
                                .frame(width: 36, height: 36)
                                .background(insight.category.color.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(insight.title)
                                    .font(.subheadline.bold())
                                
                                Text(insight.message)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Section 2: Sentiment Analysis Gauge
                Section("Reflection Sentiment (On-Device AI)") {
                    if let latest = latestReflection {
                        VStack(alignment: .leading, spacing: 12) {
                            // Latest check-in row
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Latest Check-In")
                                        .font(.subheadline.bold())
                                    HStack(spacing: 4) {
                                        Text(latest.mood.emoji)
                                        Text(latest.mood.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(latest.mood.color)
                                        if !latest.tags.isEmpty {
                                            Text("• \(latest.tags.joined(separator: ", "))")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Text(String(format: "%+.2f", latestSentiment))
                                    .font(.title3.bold())
                                    .foregroundStyle(sentimentColor(for: latestSentiment))
                            }
                            
                            ProgressView(value: max(0.0, min(1.0, (latestSentiment + 1.0) / 2.0)))
                                .tint(sentimentColor(for: latestSentiment))
                            
                            Text(sentimentDescription(for: latestSentiment))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Divider()
                                .padding(.vertical, 2)
                            
                            // Historical Average
                            HStack {
                                Text("All-Time Average (\(reflections.count) entries)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(String(format: "%+.2f", avgSentiment))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(sentimentColor(for: avgSentiment))
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("No reflections logged yet. Log your first reflection in the Journal tab to see your emotional trends!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                }
                
                // Section 3: Habit Impact Matrix
                Section("Habit Impact on Mood") {
                    if correlations.isEmpty {
                        Text("No habits tracked yet to calculate mood correlations.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(correlations) { correlation in
                            HStack(spacing: 12) {
                                Image(systemName: correlation.habitIcon)
                                    .foregroundStyle(correlation.habitColor)
                                    .frame(width: 32, height: 32)
                                    .background(correlation.habitColor.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(correlation.habitTitle)
                                        .font(.subheadline.bold())
                                    Text("\(correlation.totalCompletedDays) total completions")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(correlation.positiveDaysPercentage)% positive")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundStyle(.green)
                                    .clipShape(Capsule())
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                
                // Section 4: On-Device Machine Learning Note
                Section("Privacy & Machine Learning") {
                    HStack(spacing: 12) {
                        Image(systemName: "cpu")
                            .font(.title2)
                            .foregroundStyle(.purple)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("On-Device Apple Neural Engine")
                                .font(.subheadline.bold())
                            Text("Sentiment and correlation calculations run 100% locally via Apple's NaturalLanguage framework. No data ever leaves your iPhone.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Insights & Trends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sentimentColor(for score: Double) -> Color {
        if score > 0.15 { return .green }
        if score < -0.15 { return .orange }
        return .blue
    }
    
    private func sentimentDescription(for score: Double) -> String {
        if score > 0.2 {
            return "Your reflection demonstrates a strong positive, constructive mindset."
        } else if score < -0.2 {
            return "Your reflection indicates feelings of fatigue or stress. Prioritize self-care."
        } else {
            return "Your reflection demonstrates a balanced, grounded emotional state."
        }
    }
}

#Preview {
    InsightsDetailSheet(tasks: [], habits: [], reflections: [])
}
