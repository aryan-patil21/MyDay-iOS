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
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var selectedMood: Mood = .good
    @State private var selectedTags: Set<String> = []
    @State private var entryText: String = ""
    @State private var textBeforeRecording: String = ""
    
    private let availableTags = [
        "Grateful", "Productive", "Relaxed", "Energetic",
        "Busy", "Tired", "Anxious", "Inspired"
    ]
    
    // Real-time sentiment preview calculated on-device
    private var liveSentimentScore: Double {
        let tempReflection = DailyReflection(
            mood: selectedMood,
            tags: Array(selectedTags),
            entryText: entryText
        )
        return InsightsService.shared.sentiment(for: tempReflection)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Mood Selector
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
                
                // Section 2: Feelings & Tags
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
                
                // Section 3: Reflection with Speech-to-Text Dictation
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        // Dictation Control Header
                        HStack {
                            Text("Your Thoughts")
                                .font(.subheadline.bold())
                            
                            Spacer()
                            
                            Button {
                                toggleVoiceDictation()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: speechRecognizer.isRecording ? "waveform" : "mic.fill")
                                        .symbolEffect(.pulse, isActive: speechRecognizer.isRecording)
                                        .foregroundStyle(speechRecognizer.isRecording ? .red : .accentColor)
                                    
                                    Text(speechRecognizer.isRecording ? "Listening..." : "Dictate")
                                        .font(.caption.bold())
                                        .foregroundStyle(speechRecognizer.isRecording ? .red : .accentColor)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    speechRecognizer.isRecording ? Color.red.opacity(0.12) : Color.accentColor.opacity(0.12)
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Live Audio Level Visualizer
                        if speechRecognizer.isRecording {
                            HStack(spacing: 4) {
                                ForEach(0..<12) { index in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.red)
                                        .frame(
                                            width: 3,
                                            height: max(4, CGFloat(speechRecognizer.audioLevel * 30.0) * sin(Double(index + 1)))
                                        )
                                        .animation(.easeInOut(duration: 0.1), value: speechRecognizer.audioLevel)
                                }
                                Text("Speak naturally — transcribing on-device")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                        
                        TextField(
                            "What went well today? What are you grateful for?",
                            text: $entryText,
                            axis: .vertical
                        )
                        .lineLimit(4...8)
                        
                        // Live AI Sentiment Meter
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(sentimentColor(for: liveSentimentScore))
                            Text("Live AI Sentiment:")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%+.2f", liveSentimentScore))
                                .font(.caption.bold())
                                .foregroundStyle(sentimentColor(for: liveSentimentScore))
                            Text("(\(sentimentDescriptor(for: liveSentimentScore)))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Daily Reflection")
                } footer: {
                    if let error = speechRecognizer.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        speechRecognizer.stopRecording()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        speechRecognizer.stopRecording()
                        saveReflection()
                    }
                }
            }
            .onChange(of: speechRecognizer.transcribedText) { _, newText in
                guard !newText.isEmpty else { return }
                if textBeforeRecording.isEmpty {
                    entryText = newText
                } else {
                    entryText = "\(textBeforeRecording) \(newText)"
                }
            }
        }
    }
    
    private func toggleVoiceDictation() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            textBeforeRecording = entryText
            Task {
                await speechRecognizer.startRecording()
            }
        }
    }
    
    private func sentimentColor(for score: Double) -> Color {
        if score > 0.15 { return .green }
        if score < -0.15 { return .orange }
        return .blue
    }
    
    private func sentimentDescriptor(for score: Double) -> String {
        if score > 0.3 { return "Optimistic" }
        if score > 0.05 { return "Constructive" }
        if score > -0.15 { return "Balanced" }
        return "Reflective"
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
