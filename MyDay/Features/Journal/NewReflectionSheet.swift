//
//  NewReflectionSheet.swift
//  MyDay
//
//  Created by Apple on 08/09/26.
//

import SwiftUI
import SwiftData

struct NewReflectionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMood: Mood = .good
    @State private var selectedTags: Set<String> = []
    @State private var entryText: String = ""
    
    private let availableTags = [
        "Grateful", "Productive", "Relaxed", "Energetic",
        "Busy", "Tired", "Anxious", "Inspired"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("How are you feeling?") {
                    HStack(spacing: 8) {
                        ForEach(Mood.allCases) { mood in
                            Button {
                                selectedMood = mood
                            } label: {
                                VStack(spacing: 4) {
                                    Text(mood.emoji)
                                        .font(.system(size: 28))
                                    Text(mood.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(selectedMood == mood ? mood.color : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedMood == mood ? mood.color.opacity(0.15) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Feelings & Highlights") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(availableTags, id: \.self) { tag in
                            let isSelected = selectedTags.contains(tag)
                            Button {
                                if isSelected {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            } label: {
                                Text(tag)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? selectedMood.color : Color(uiColor: .tertiarySystemFill))
                                    .foregroundStyle(isSelected ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Daily Reflection") {
                    TextField(
                        "What went well today? What are you grateful for?",
                        text: $entryText,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                }
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReflection()
                    }
                }
            }
        }
    }
    
    private func saveReflection() {
        let newReflection = DailyReflection(
            mood: selectedMood,
            tags: Array(selectedTags),
            entryText: entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(newReflection)
        dismiss()
    }
}

#Preview {
    NewReflectionSheet()
        .modelContainer(for: DailyReflection.self, inMemory: true)
}
