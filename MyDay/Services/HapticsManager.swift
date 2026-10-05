//
//  HapticsManager.swift
//  MyDay
//
//  Created by Apple on 05/10/26.
//

import UIKit

/// Central manager for crisp, intentional haptic feedback throughout MyDay.
@MainActor
final class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    /// Triggered for subtle selection changes (tabs, segmented controls, list ticks, small steps).
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Triggered for tactile impacts (start/stop actions, releases, buttons).
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggered for notifications (task completion, goal reached, error).
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// Convenience for task or habit completion.
    func success() {
        notification(.success)
    }
    
    /// Convenience for warnings or destructive alerts.
    func warning() {
        notification(.warning)
    }
}
