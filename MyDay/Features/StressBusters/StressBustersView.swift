//
//  StressBustersView.swift
//  MyDay
//
//  Created by Apple on 19/09/26.
//

import SwiftUI
import Combine

// MARK: - Stress Busters Hub View

struct StressBustersView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Subtitle
                    Text("Take a pause whenever you feel overwhelmed. Choose an exercise to reset your mind.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    
                    // 1. Breathing Card
                    NavigationLink {
                        BreathingActivityView()
                    } label: {
                        stressBusterCard(
                            title: "Guided Breathing",
                            subtitle: "Inhale, hold, and exhale with a visual countdown to calm your heart rate.",
                            icon: "wind",
                            color: .cyan,
                            tag: "2-3 min"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // 2. Quick Reflection Card
                    NavigationLink {
                        QuickReflectionActivityView()
                    } label: {
                        stressBusterCard(
                            title: "Quick Reflection",
                            subtitle: "Identify and release one thought or burden outside your control today.",
                            icon: "sparkles",
                            color: .purple,
                            tag: "1-2 min"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // 3. Grounding Card
                    NavigationLink {
                        GroundingActivityView()
                    } label: {
                        stressBusterCard(
                            title: "5-4-3-2-1 Grounding",
                            subtitle: "Engage your five senses to reconnect with the physical present moment.",
                            icon: "leaf.fill",
                            color: .green,
                            tag: "3-5 min"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle("Stress Busters")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func stressBusterCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        tag: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(tag)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .clipShape(Capsule())
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 1. Breathing Activity View

struct BreathingActivityView: View {
    @State private var isActive = false
    @State private var phase: BreathPhase = .ready
    @State private var secondsRemaining = 4
    @State private var scale: CGFloat = 0.6
    @State private var timerSubscription: AnyCancellable?
    
    enum BreathPhase {
        case ready
        case inhale
        case hold
        case exhale
        
        var title: String {
            switch self {
            case .ready: return "Ready"
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            }
        }
        
        var color: Color {
            switch self {
            case .ready: return .secondary
            case .inhale: return .cyan
            case .hold: return .blue
            case .exhale: return .purple
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 36) {
            Spacer()
            
            // Pulsing Ring & Timer
            ZStack {
                Circle()
                    .stroke(phase.color.opacity(0.2), lineWidth: 4)
                    .frame(width: 240, height: 240)
                
                Circle()
                    .fill(phase.color.opacity(0.25))
                    .frame(width: 220, height: 220)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: Double(secondsRemaining)), value: scale)
                
                VStack(spacing: 8) {
                    Text(phase.title)
                        .font(.title2.bold())
                        .foregroundStyle(phase.color)
                    
                    if isActive {
                        Text("\(secondsRemaining)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            Text(instructionText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Start / Stop Controls
            Button {
                if isActive {
                    stopBreathing()
                } else {
                    startBreathing()
                }
            } label: {
                Text(isActive ? "Stop" : "Start Breathing")
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isActive ? Color.secondary.opacity(0.3) : Color.cyan)
                    .foregroundStyle(isActive ? Color.primary : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .navigationTitle("Guided Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopBreathing()
        }
    }
    
    private var instructionText: String {
        switch phase {
        case .ready: return "Find a comfortable position and press Start to begin."
        case .inhale: return "Slowly draw air deep into your lungs."
        case .hold: return "Gently hold your breath without straining."
        case .exhale: return "Release slowly and completely through your mouth."
        }
    }
    
    private func startBreathing() {
        isActive = true
        transitionTo(phase: .inhale, duration: 4)
        
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                tick()
            }
    }
    
    private func stopBreathing() {
        timerSubscription?.cancel()
        timerSubscription = nil
        isActive = false
        phase = .ready
        secondsRemaining = 4
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.6
        }
    }
    
    private func tick() {
        guard isActive else { return }
        if secondsRemaining > 1 {
            secondsRemaining -= 1
        } else {
            // Move to next phase
            switch phase {
            case .ready, .exhale:
                transitionTo(phase: .inhale, duration: 4)
            case .inhale:
                transitionTo(phase: .hold, duration: 4)
            case .hold:
                transitionTo(phase: .exhale, duration: 4)
            }
        }
    }
    
    private func transitionTo(phase: BreathPhase, duration: Int) {
        self.phase = phase
        self.secondsRemaining = duration
        withAnimation(.easeInOut(duration: Double(duration))) {
            switch phase {
            case .inhale: scale = 1.0
            case .hold: scale = 1.0
            case .exhale: scale = 0.6
            case .ready: scale = 0.6
            }
        }
    }
}

// MARK: - 2. Quick Reflection Activity View

struct QuickReflectionActivityView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var reflectionInput = ""
    @State private var isReleased = false
    
    var body: some View {
        VStack(spacing: 24) {
            if !isReleased {
                VStack(spacing: 8) {
                    Text("What is one thing you can let go of for today?")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)
                    
                    Text("Acknowledge what is outside your control. Writing it down helps free mental space.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                TextField("Write your thought here...", text: $reflectionInput, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isReleased = true
                        }
                    } label: {
                        Text("Let It Go")
                            .font(.body.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            } else {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.purple)
                    
                    Text("Thought Released")
                        .font(.title2.bold())
                    
                    Text("You've given yourself permission to let go for today. Take a slow, deep breath and return when you're ready.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Quick Reflection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 3. Grounding Activity View (5-4-3-2-1)

struct GroundingActivityView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 1
    
    private let steps: [(count: Int, sense: String, icon: String, prompt: String, color: Color)] = [
        (5, "SEE", "eye.fill", "Notice 5 things around you that you can see. Look for colors, shapes, or light reflecting on surfaces.", .blue),
        (4, "TOUCH", "hand.tap.fill", "Notice 4 things you can feel physically. The texture of your shirt, the cool table, or your feet on the floor.", .teal),
        (3, "HEAR", "ear.fill", "Listen for 3 distinct sounds. Traffic outside, a humming computer, or distant conversations.", .green),
        (2, "SMELL", "nose.fill", "Notice 2 scents in the air. Fresh air, coffee, pencil wood, or simply the scent of your room.", .orange),
        (1, "TASTE", "mouth.fill", "Notice 1 thing you can taste. Take a sip of water, or focus on the current taste inside your mouth.", .purple)
    ]
    
    var body: some View {
        VStack(spacing: 28) {
            if currentStep <= 5 {
                let step = steps[currentStep - 1]
                
                // Step Progress Bar
                ProgressView(value: Double(currentStep), total: 5.0)
                    .tint(step.color)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                Text("Step \(currentStep) of 5")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Spacer()
                
                // Step Card
                VStack(spacing: 18) {
                    Image(systemName: step.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(step.color)
                    
                    Text("\(step.count) Things You Can \(step.sense)")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(step.prompt)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .padding(24)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Next Button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                } label: {
                    Text(currentStep == 5 ? "Complete Grounding" : "Next Sense")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(step.color)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            } else {
                // Completed State
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                    
                    Text("Grounding Complete")
                        .font(.title2.bold())
                    
                    Text("You have reconnected with the physical present moment. Carry this calm with you as you continue your day.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("5-4-3-2-1 Grounding")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StressBustersView()
}
