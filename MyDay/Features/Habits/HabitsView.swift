//
//  HabitsView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]
    
    @State private var showingNewHabitSheet = false
    
    private var completedTodayCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    private var completionRate: Double {
        guard !habits.isEmpty else { return 0.0 }
        return Double(completedTodayCount) / Double(habits.count)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    emptyStateView
                } else {
                    List {
                        Section {
                            progressHeaderCard
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        
                        Section("My Habits (\(habits.count))") {
                            ForEach(habits) { habit in
                                HabitRowView(habit: habit) {
                                    toggleHabit(habit)
                                }
                            }
                            .onDelete(perform: deleteHabits)
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewHabitSheet = true
                    } label: {
                        Label("Add Habit", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewHabitSheet) {
                NewHabitSheet()
            }
        }
    }
    
    private var progressHeaderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                Spacer()
                Text("\(completedTodayCount) of \(habits.count) completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: completionRate)
                .tint(completedTodayCount == habits.count ? .green : .orange)
            
            Text(progressMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var progressMessage: String {
        if habits.isEmpty {
            return "Add a habit to get started."
        } else if completedTodayCount == habits.count {
            return "🎉 All habits completed for today! Great job!"
        } else if completedTodayCount > 0 {
            return "Keep the momentum going!"
        } else {
            return "Start your day by checking off your first habit."
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Habits Yet", systemImage: "flame")
        } description: {
            Text("Build consistency by creating daily habits and tracking your streaks.")
        } actions: {
            Button("Add Habit") {
                showingNewHabitSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func toggleHabit(_ habit: Habit) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habit.toggleCompletionToday()
        }
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(habits[index])
            }
        }
    }
}

#Preview {
    HabitsView()
        .modelContainer(for: Habit.self, inMemory: true)
}
