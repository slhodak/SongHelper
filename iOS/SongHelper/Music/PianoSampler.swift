//
//  PianoSampler.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/11/24.
//

import Foundation
import AudioKit


class PianoSampler {
    private let engine = AudioEngine()
    private let sampler = AppleSampler()
    private var currentNotes: Set<UInt8> = []
    
    func setup() {
        setupEngine()
        loadInstrument()
    }
    
    func setupEngine() {
        engine.output = sampler
        do {
            try engine.start()
        } catch {
            Log("Could not start audio engine")
        }
    }
    
    func loadInstrument() {
        do {
            if let fileURL = Bundle.main.url(forResource: "Keyboards", withExtension: "sf2") {
                try sampler.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
    }
    
    func notesOn(notes: [UInt8]) {
        for note in notes {
            sampler.play(noteNumber: note, velocity: 90, channel: 0)
            currentNotes.insert(note)
        }
    }
    
    func notesOff() {
        var notesToRemove: [UInt8] = []
        
        for note in currentNotes {
            sampler.stop(noteNumber: MIDINoteNumber(note), channel: 0)
            notesToRemove.append(note)
        }
        
        for note in notesToRemove {
            currentNotes.remove(note)
        }
    }
}
