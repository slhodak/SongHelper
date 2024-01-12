//
//  HandPoseMusicController.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/10/24.
//

import Foundation
import Vision
import Combine


enum MusicalMode {
    case major
    case minor
}

struct FingerTipsMessage {
    var fingerTipGroup: Int
    var thumbLocation: CGPoint?
}

enum SHInstrument {
    case sampler
    case synthesizer
}


class HandPoseMusicController: ObservableObject {
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    private var pianoSampler = PianoSampler()
    private var useInstrument: SHInstrument = .sampler
    private var isPlaying: Bool = false
    
    @Published var keyRoot: Int = 24 // C1
    var octave = 4
    @Published var musicalMode: MusicalMode = .major
    
    var leftHandFingerTipGroup: Int = 0b0 // 0000
    var leftHandThumbLocation: CGPoint?
    var rightHandFingerTipGroup: Int = 0b0 // 0000
    
    private var rightHandSubscriber: AnyCancellable?
    private var leftHandSubscriber: AnyCancellable?
    
    let scaleDegreeForFingerTipGroup: [Int: Int] = [
        0b0001: 1,
        0b0010: 2,
        0b0011: 3,
        0b0100: 4,
        0b0101: 5,
        0b0110: 6,
        0b0111: 7,
    ]
    // These can be chosen automatically based on scale degree in key, but modified if right hand says so
    let chordTypeForFingerTipGroup: [Int: Chord] = [
        0b0001: .majorTriad,
        0b0010: .minorTriad,
        0b0011: .halfDim,
        0b0100: .major7,
        0b0101: .dominant7,
        0b0110: .minor7,
        0b0111: .fullDim,
    ]
    
    init(leftHand: HandPose, rightHand: HandPose) {
        pianoSampler.setup()
        
        self.leftHandSubscriber = leftHand.fingerTipGroupPublisher
            .sink(receiveValue: handleLeftHandUpdate)
        self.rightHandSubscriber = rightHand.fingerTipGroupPublisher
            .sink(receiveValue: handleRightHandUpdate)
    }
    
    func handleLeftHandUpdate(message: FingerTipsMessage) {
        // Update thumb location regardless of whether fingertip group changed,
        // because it controls dynamics and notes can be triggered by right hand too
        self.leftHandThumbLocation = message.thumbLocation
        
        guard self.leftHandFingerTipGroup != message.fingerTipGroup else { return }
        
        self.leftHandFingerTipGroup = message.fingerTipGroup
        self.stopMusic()
        self.playMusic(for: message.fingerTipGroup, with: message.thumbLocation)
    }
    
    func handleRightHandUpdate(message: FingerTipsMessage) {
        guard self.rightHandFingerTipGroup != message.fingerTipGroup else { return }
        
        self.rightHandFingerTipGroup = message.fingerTipGroup
        if self.isPlaying {
            self.stopMusic()
            self.playMusic(for: self.leftHandFingerTipGroup, with: self.leftHandThumbLocation)
        }
    }
    
    func setMusicalMode(to musicalMode: MusicalMode) {
        self.musicalMode = musicalMode
    }
    
    func getNotesToPlay(for fingerTipGroup: Int) -> [Int]? {
        guard let scaleDegree = scaleDegreeForFingerTipGroup[fingerTipGroup] else {
            polyphonicPlayer.noteOff()
            return nil
        }
        
        // Convert the scale degree into a number of semitones above the root
        let midiInterval = scaleDegreeToMidiInterval(musicalMode: musicalMode, scaleDegree: scaleDegree)
        guard let midiInterval = midiInterval else { return nil }
        
        // Get the chord type, either regular for scale or as modified by right hand if present
        var chordType = chordTypeForFingerTipGroup[rightHandFingerTipGroup]
        if chordType == nil {
            chordType = getRegularChordTypeFor(musicalMode: musicalMode, scaleDegree: scaleDegree)
        }
        guard let chordType = chordType else { return nil }
        
        let chordRoot = getChordRoot(keyRoot: keyRoot, octave: octave, midiInterval: midiInterval)
        return getChord(root: chordRoot, tones: chordType.values)
    }
    
    func getVelocity(from thumbLocation: CGPoint) -> UInt8 {
        return UInt8(thumbLocation.y * 50) + 50
    }
    
    func playMusic(for fingerTipGroup: Int, with thumbLocation: CGPoint? = nil) {
        guard let notes = getNotesToPlay(for: fingerTipGroup) else {
            return
        }
        
        isPlaying = true
        
        if useInstrument == .sampler {
            // Just until I change all midi note types to UInt8 from Int
            var castNotes: [UInt8] = []
            for note in notes {
                castNotes.append(UInt8(note))
            }
            
            var velocity = UInt8(77)
            if thumbLocation != nil {
                velocity = getVelocity(from: thumbLocation!)
            }
            pianoSampler.notesOn(notes: castNotes, velocity: velocity)
        } else if useInstrument == .synthesizer {
            polyphonicPlayer.noteOn(notes: notes)
        }
    }
    
    func stopMusic() {
        isPlaying = false
        
        // would be more robust to have an ActiveInstrument or something?
        // but also would be harder to read?
        if useInstrument == .sampler {
            pianoSampler.notesOff()
        } else if useInstrument == .synthesizer {
            polyphonicPlayer.noteOff()
        }
    }
}
