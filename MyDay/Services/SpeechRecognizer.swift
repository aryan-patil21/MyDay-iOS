//
//  SpeechRecognizer.swift
//  MyDay
//
//  Created by Apple on 19/09/26.
//

import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
final class SpeechRecognizer: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var transcribedText: String = ""
    @Published var errorMessage: String? = nil
    @Published var audioLevel: Float = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    
    init() {}
    
    /// Requests both microphone and speech recognition permissions
    func requestPermissions() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        
        guard speechAuthorized else {
            errorMessage = "Speech recognition access was denied. Enable it in Settings."
            return false
        }
        
        let micAuthorized = await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        
        guard micAuthorized else {
            errorMessage = "Microphone access was denied. Enable it in Settings."
            return false
        }
        
        return true
    }
    
    /// Starts live audio capture and speech-to-text transcription
    func startRecording() async {
        guard !isRecording else { return }
        
        let hasPermissions = await requestPermissions()
        guard hasPermissions else { return }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer is not available on this device right now."
            return
        }
        
        stopRecording()
        errorMessage = nil
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let engine = AVAudioEngine()
            self.audioEngine = engine
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            
            // Prefer on-device processing for privacy & performance
            if speechRecognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            }
            self.recognitionRequest = request
            
            let inputNode = engine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                request.append(buffer)
                
                // Calculate audio level (RMS) for live waveform feedback
                guard let channelData = buffer.floatChannelData?[0] else { return }
                let frameLength = UInt(buffer.frameLength)
                var sum: Float = 0
                for i in 0..<Int(frameLength) {
                    let sample = channelData[i]
                    sum += sample * sample
                }
                let rms = sqrt(sum / Float(frameLength))
                let normalized = max(0.0, min(1.0, rms * 5.0))
                
                Task { @MainActor in
                    self?.audioLevel = normalized
                }
            }
            
            engine.prepare()
            try engine.start()
            
            self.isRecording = true
            
            self.recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    Task { @MainActor in
                        self.transcribedText = result.bestTranscription.formattedString
                    }
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    Task { @MainActor in
                        self.stopRecording()
                    }
                }
            }
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            stopRecording()
        }
    }
    
    /// Stops speech transcription and releases audio hardware
    func stopRecording() {
        if audioEngine?.isRunning == true {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
        }
        audioEngine = nil
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
        audioLevel = 0.0
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    /// Clears transcribed text and state
    func reset() {
        stopRecording()
        transcribedText = ""
        errorMessage = nil
    }
}
