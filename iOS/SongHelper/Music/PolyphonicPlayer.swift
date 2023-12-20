//
//  PolyphonicPlayer.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation
import AudioKit
import SoundpipeAudioKit


// Example:
//      polyphonicPlayer.noteOn(notes: getChord(root: root, offset: 0, tones: majorTriad))

class PolyphonicPlayer {
    let engine = AudioEngine()
    var oscillators: [Oscillator] = []
    let mixer = Mixer()
    var envelopes: Array<AmplitudeEnvelope> = []
    var isPlaying = false
    
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
    
    func noteOn(notes: [Int]) {
        guard !isPlaying else { return }
        
        print("Playing notes: \(notes.map { String($0) }))")
        isPlaying = true
        for (i, note) in notes.enumerated() {
            let osc = oscillators[i]
            let envelope = envelopes[i]
            osc.frequency = AUValue(note).midiNoteToFrequency()
            envelope.openGate()
        }
    }
    
    func noteOff() {
        for envelope in envelopes {
            envelope.closeGate()
        }
        isPlaying = false
    }
    
    func createEnvelope(osc: Oscillator) -> AmplitudeEnvelope {
        return AmplitudeEnvelope(
            osc,
            attackDuration: 0.01,
            decayDuration: 0.0,
            sustainLevel: 1.0,
            releaseDuration: 0.1)
    }
}
