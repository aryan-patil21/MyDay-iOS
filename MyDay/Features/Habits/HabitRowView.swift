//
//  HabitRowView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon Badge
            Image(systemName: habit.iconName)
                .font(.title3)
                .foregroundStyle(habit.themeColor)
                .frame(width: 44, height: 44)
                .background(habit.themeColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Title & Streak
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(habit.currentStreak > 0 ? .orange : .secondary)
                    
                    Text("\(habit.currentStreak) day streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Check-in Toggle Button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(habit.isCompletedToday ? habit.themeColor : Color.secondary.opacity(0.3), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(habit.isCompletedToday ? habit.themeColor : Color.clear)
                        )
                        .frame(width: 34, height: 34)
                    
                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
