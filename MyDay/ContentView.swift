//
//  ContentView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isShowingSplash = true
    @State private var splashOpacity: Double = 1.0

    var body: some View {
        ZStack {
            // Existing MyDay TabView
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
