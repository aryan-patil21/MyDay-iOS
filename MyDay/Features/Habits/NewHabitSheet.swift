//
//  NewHabitSheet.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct NewHabitSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var selectedIcon: String = "flame.fill"
    @State private var selectedColor: String = "orange"
    
    private let availableIcons = [
        "flame.fill", "drop.fill", "figure.run", "book.fill",
        "bed.double.fill", "cup.and.saucer.fill", "heart.fill", "dumbbell.fill",
        "brain.head.profile", "leaf.fill", "fork.knife", "moon.stars.fill"
    ]
    
    private let availableColors = [
        "blue", "green", "purple", "orange", "pink", "teal", "indigo"
    ]
    
    private func color(for name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .orange
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Name") {
                    TextField("e.g., Morning Meditation, Drink Water", text: $title)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 14) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(selectedIcon == icon ? color(for: selectedColor) : .secondary)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedIcon == icon ? color(for: selectedColor).opacity(0.15) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedIcon == icon ? color(for: selectedColor) : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                Section("Theme Color") {
                    HStack(spacing: 14) {
                        ForEach(availableColors, id: \.self) { cName in
                            Button {
                                selectedColor = cName
                            } label: {
                                Circle()
                                    .fill(color(for: cName))
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == cName ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveHabit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newHabit = Habit(
            title: trimmedTitle,
            iconName: selectedIcon,
            colorName: selectedColor
        )
        modelContext.insert(newHabit)
        dismiss()
    }
}

#Preview {
    NewHabitSheet()
        .modelContainer(for: Habit.self, inMemory: true)
}
