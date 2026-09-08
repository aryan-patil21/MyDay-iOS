//
//  JournalView.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyReflection.date, order: .reverse) private var reflections: [DailyReflection]
    
    @State private var showingNewReflectionSheet = false
    
    private var hasReflectedToday: Bool {
        reflections.contains { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if reflections.isEmpty {
                    emptyStateView
                } else {
                    List {
                        Section {
                            todayStatusBanner
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        
                        Section("Past Reflections (\(reflections.count))") {
                            ForEach(reflections) { reflection in
                                ReflectionCardView(reflection: reflection)
                            }
                            .onDelete(perform: deleteReflections)
                        }
                    }
                }
            }
            .navigationTitle("Journal & Mood")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewReflectionSheet = true
                    } label: {
                        Label("Check In", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewReflectionSheet) {
                NewReflectionSheet()
            }
        }
    }
    
    private var todayStatusBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: hasReflectedToday ? "sparkles" : "sun.max.fill")
                .font(.title2)
                .foregroundStyle(hasReflectedToday ? .purple : .orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(hasReflectedToday ? "Today's check-in complete!" : "How was your day?")
                    .font(.subheadline.bold())
                Text(hasReflectedToday ? "Great job taking time for self-reflection." : "Take 60 seconds to log your mood and thoughts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if !hasReflectedToday {
                Button("Check In") {
                    showingNewReflectionSheet = true
                }
                .font(.caption.bold())
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Reflections Yet", systemImage: "book.pages")
        } description: {
            Text("Take a mindful moment every day to capture how you feel and reflect on your highlights.")
        } actions: {
            Button("Log First Reflection") {
                showingNewReflectionSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func deleteReflections(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(reflections[index])
            }
        }
    }
}

#Preview {
    JournalView()
        .modelContainer(for: DailyReflection.self, inMemory: true)
}
