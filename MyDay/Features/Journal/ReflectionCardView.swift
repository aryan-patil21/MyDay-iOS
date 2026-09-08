//
//  ReflectionCardView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI

struct ReflectionCardView: View {
    let reflection: DailyReflection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Mood emoji and name badge
                HStack(spacing: 6) {
                    Text(reflection.mood.emoji)
                        .font(.title3)
                    Text(reflection.mood.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(reflection.mood.color)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(reflection.mood.color.opacity(0.15))
                .clipShape(Capsule())
                
                Spacer()
                
                Text(reflection.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !reflection.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(reflection.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(uiColor: .tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                }
            }
            
            if !reflection.entryText.isEmpty {
                Text(reflection.entryText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(4)
            }
        }
        .padding(.vertical, 4)
    }
}
