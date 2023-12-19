//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AudioKit
import SoundpipeAudioKit


struct ContentView: View {
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    
    var body: some View {
        VStack {
            ChordButton(
                title: "CMaj",
                onPress: { polyphonicPlayer.noteOn(notes: [60, 64, 67], for: 1) },
                onUnpress: polyphonicPlayer.noteOff)
            ChordButton(
                title: "Dmin",
                onPress: { polyphonicPlayer.noteOn(notes: [62, 65, 69], for: 1) },
                onUnpress: polyphonicPlayer.noteOff)
            ChordButton(
                title: "Emin",
                onPress: { polyphonicPlayer.noteOn(notes: [64, 67, 71], for: 1) },
                onUnpress: polyphonicPlayer.noteOff)
            ChordButton(
                title: "FMaj",
                onPress: { polyphonicPlayer.noteOn(notes: [60, 65, 69], for: 1) },
                onUnpress: polyphonicPlayer.noteOff)
            ChordButton(
                title: "GMaj",
                onPress: { polyphonicPlayer.noteOn(notes: [62, 67, 71], for: 1) },
                onUnpress: polyphonicPlayer.noteOff)
            ChordButton(
                title: "Amin",
                onPress: { polyphonicPlayer.noteOn(notes: [60, 64, 69], for: 1) },
                onUnpress: polyphonicPlayer.noteOff)
            ChordButton(
                title: "Bdim",
                onPress: { polyphonicPlayer.noteOn(notes: [62, 65, 71], for: 1) },
                onUnpress: polyphonicPlayer.noteOff)
        }
    }
}

#Preview {
    ContentView()
}

class PolyphonicPlayer {
    let engine = AudioEngine()
    var oscillators: [Oscillator] = []
    let mixer = Mixer()
    var envelopes: Array<AmplitudeEnvelope> = []
    
    init(voices: Int) {
        for _ in 0...voices {
            let osc = Oscillator()
            osc.amplitude = 0.2
            osc.start()
            oscillators.append(osc)
            
            let envelope = createEnvelope(osc: osc)
            envelopes.append(envelope)
            mixer.addInput(envelope)
        }
        
        engine.output = mixer
        
        do {
            try engine.start()
        } catch {
            print("Could not start AudioEngine")
        }
    }
    
    func noteOn(notes: [Int], for duration: Double) {
        print("Playing notes")
        var i = 0
        for note in notes {
            let osc = oscillators[i]
            let envelope = envelopes[i]
            osc.frequency = AUValue(note).midiNoteToFrequency()
            envelope.openGate()
            i += 1
        }
    }
    
    func noteOff() {
        for envelope in envelopes {
            envelope.closeGate()
        }
    }
    
    func createEnvelope(osc: Oscillator) -> AmplitudeEnvelope {
        var env = AmplitudeEnvelope(osc)
        env.attackDuration = 0.01
        env.decayDuration = 0.0
        env.sustainLevel = 1.0
        env.releaseDuration = 0.1
        return env
    }
}

struct ChordButton: View {
    var title: String
    var onPress: () -> Void
    var onUnpress: () -> Void
    
    var body: some View {
        Text(title)
            .frame(width: 200, height: 50) // Set the size of the button
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2) // Add a border
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onUnpress()
                    }
            )
    }
}
