//
//  ContentView.swift
//  Taptic
//
//  Created by Eli Serrano on 2/21/24.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    @State private var isPlaying = false
    private var hapticEngine: CHHapticEngine?

    init() {
        if hapticEngine == nil { // Only initialize if not already done
            prepareHaptics()
        }
    }

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 80))
                .onTapGesture {
                    togglePlayback()  // Implement your sound recognition and haptic response here
                }

            Text("Taptic")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }

    func startSoundRecognition() {
        do {
            try streamAnalyzer.add(request, withObserver: self)
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Error setting up audio analysis: \(error.localizedDescription)")
        }
    }

    // MARK: - Observation Results
    extension ContentView: SNResultsObserving {
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let result = result as? SNClassificationResult else { return }
            let sortedClassifications = result.classifications.sorted { $0.confidence > $1.confidence }

            if let topClassification = sortedClassifications.first {
                handleSoundDetected(soundIdentifier: topClassification.identifier)
            }
        }
    }

    func handleSoundDetected(soundIdentifier: String) {
        // Trigger haptic feedback based on the soundIdentifier
        os_log("Sound recognized: %@", log: .default, type: .info, soundIdentifier) // Add your logging here
    }

    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
          //  hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine creation failed: \(error.localizedDescription)")
        }
    }

    func togglePlayback() {
        isPlaying.toggle()

        // Replace this with your sound recognition and haptic pattern generation logic
        if isPlaying {
            // Example: Play a simple haptic pattern
            playSimpleHaptic()
        }
    }

    func playSimpleHaptic() {
        // You'll need more sophisticated haptic patterns for real-world use
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

