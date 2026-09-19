//
//  ContentView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    @State private var isShowingSplash = true
    @State private var splashOpacity: Double = 1.0

    private var preferredColorScheme: ColorScheme? {
        switch appAppearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        ZStack {
            // Main App or Onboarding Flow
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
            
            // Startup Splash Animation Overlay
            if isShowingSplash {
                StartupSplashView {
                    withAnimation(.easeOut(duration: 0.3)) {
                        splashOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isShowingSplash = false
                    }
                }
                .opacity(splashOpacity)
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .preferredColorScheme(preferredColorScheme)
    }

    // MARK: - Main Tab View (Existing App Navigation)

    private var mainTabView: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
            
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "flame.fill")
                }
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages.fill")
                }
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    var onContinueAsGuest: () -> Void
    
    @State private var showingAppleNotice = false
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Header Branding
            VStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Welcome to MyDay")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Your private daily companion for habits, tasks, and reflections.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // Feature Highlights
            VStack(alignment: .leading, spacing: 18) {
                onboardingFeatureRow(
                    icon: "flame.fill",
                    color: .orange,
                    title: "Habit Streaks",
                    subtitle: "Build healthy routines with daily consistency tracking."
                )
                
                onboardingFeatureRow(
                    icon: "checklist",
                    color: .green,
                    title: "Focus Tasks",
                    subtitle: "Keep your daily priorities organized and manageable."
                )
                
                onboardingFeatureRow(
                    icon: "sparkles",
                    color: .purple,
                    title: "Daily Reflections",
                    subtitle: "Reflect on your mood with on-device private insights."
                )
            }
            .padding(.horizontal, 28)
            
            Spacer()
            
            // Auth Actions
            VStack(spacing: 12) {
                // Continue with Apple (Placeholder per requirements)
                Button {
                    showingAppleNotice = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Continue with Apple")
                            .font(.body.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primary)
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                
                // Continue as Guest (Active path)
                Button {
                    onContinueAsGuest()
                } label: {
                    Text("Continue as Guest")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(uiColor: .secondarySystemFill))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                
                Text("Guest data is stored locally on this device.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .alert("Apple Sign-In", isPresented: $showingAppleNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Apple Sign-In will be available in an upcoming update. Please continue as Guest to start using MyDay.")
        }
    }
    
    private func onboardingFeatureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Startup Splash Animation View

struct StartupSplashView: View {
    var onFinished: () -> Void
    
    @State private var iconScale: CGFloat = 0.75
    @State private var iconOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var glowRadius: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    // Soft warm ambient glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.orange.opacity(0.4), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: glowRadius)
                    
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.35), radius: 12, x: 0, y: 4)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                
                VStack(spacing: 4) {
                    Text("MyDay")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Your day, your way")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            runAnimation()
        }
    }
    
    private func runAnimation() {
        // Step 1: Icon scales up smoothly and glows (0.0s - 0.5s)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            iconScale = 1.0
            iconOpacity = 1.0
            glowRadius = 20.0
        }
        
        // Step 2: Title and tagline fade in (0.25s - 0.6s)
        withAnimation(.easeOut(duration: 0.35).delay(0.25)) {
            textOpacity = 1.0
        }
        
        // Step 3: Trigger completion at ~0.95s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            onFinished()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TaskItem.self, Habit.self, DailyReflection.self], inMemory: true)
}
