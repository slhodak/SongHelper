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
    private var cMajChordPlayer = ChordPlayer([60, 64, 67])
    private var dMinChordPlayer = ChordPlayer([62, 65, 69])
    private var eMinChordPlayer = ChordPlayer([64, 67, 71])
    private var fMajChordPlayer = ChordPlayer([60, 65, 69])
    private var gMajChordPlayer = ChordPlayer([62, 67, 71])
    private var aMinChordPlayer = ChordPlayer([60, 64, 69])
    private var bDimChordPlayer = ChordPlayer([62, 65, 71])
    
    var body: some View {
        VStack {
            ChordButton(title: "CMaj") {
                cMajChordPlayer.playFor(duration: 1)
            }
            ChordButton(title: "Dmin") {
                dMinChordPlayer.playFor(duration: 1)
            }
            ChordButton(title: "Emin") {
                eMinChordPlayer.playFor(duration: 1)
            }
            ChordButton(title: "FMaj") {
                fMajChordPlayer.playFor(duration: 1)
            }
            ChordButton(title:"GMaj") {
                gMajChordPlayer.playFor(duration: 1)
            }
            ChordButton(title: "Amin") {
                aMinChordPlayer.playFor(duration: 1)
            }
            ChordButton(title: "Bdim") {
                bDimChordPlayer.playFor(duration: 1)
            }
        }
    }
}

#Preview {
    ContentView()
}

class ChordPlayer {
    let engine = AudioEngine()
    var oscillators: [Oscillator] = []
    let mixer = Mixer()
    let adsr = ADSREnvelope()
    
    init(_ chordNotes: [Int]) {
        // Configure ADSR envelope
        adsr.attackDuration = 0.1  // Adjust as needed
        adsr.decayDuration = 0.1   // Adjust as needed
        adsr.sustainLevel = 0.8    // Adjust as needed
        adsr.releaseDuration = 0.1 // Adjust as needed
        
        for note in chordNotes {
            let osc = Oscillator()
            osc.frequency = AUValue(note).midiNoteToFrequency()
            let oscWithEnv = osc => adsr
            oscillators.append(oscWithEnv)
        }
        
        for osc in oscillators {
            osc.amplitude = 0.2
            mixer.addInput(osc)
        }
        
        engine.output = mixerWithEnvelope
        
        do {
            try engine.start()
        } catch {
            print("Could not start AudioEngine")
        }
    }
    
    func playFor(duration: Double) {
        print("Playing note")
        for osc in oscillators {
            osc.start()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            for osc in self.oscillators {
                osc.stop()
            }
        })
    }
}

struct ChordButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 200, height: 50) // Set the size of the button
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10) // Rounded corners
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2) // Add a border
                )
        }
    }
}
