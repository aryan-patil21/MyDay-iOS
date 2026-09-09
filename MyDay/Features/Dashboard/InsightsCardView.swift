//
//  InsightsCardView.swift
//  MyDay
//
//  Created by Apple on 09/09/26.
//

import SwiftUI

struct InsightsCardView: View {
    let insights: [InsightItem]
    var onViewDetails: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundStyle(.purple)
                    
                    Text("AI Daily Insights")
                        .font(.headline)
                }
                
                Spacer()
                
                Button(action: onViewDetails) {
                    HStack(spacing: 2) {
                        Text("View Details")
                            .font(.caption.bold())
                        Image(systemName: "chevron.right")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(.purple)
                }
            }
            
            // Top Insight Preview
            if let primaryInsight = insights.first {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: primaryInsight.category.icon)
                        .font(.body)
                        .foregroundStyle(primaryInsight.category.color)
                        .frame(width: 34, height: 34)
                        .background(primaryInsight.category.color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(primaryInsight.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                        
                        Text(primaryInsight.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.10),
                            Color.indigo.opacity(0.04),
                            Color(uiColor: .secondarySystemGroupedBackground)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}
