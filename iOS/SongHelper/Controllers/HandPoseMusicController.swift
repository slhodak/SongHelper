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
    
    @Published var keyRoot: UInt8 = 24 // C1
    var octave: UInt8 = 4
    @Published var musicalMode: MusicalMode = .major
    @Published var chordRoot: UInt8 = 24
    @Published var chordType: Chord = .majorTriad
    
    var leftHandFingerTipGroup: Int = 0b0 // 0000
    var leftHandThumbLocation: CGPoint?
    var rightHandFingerTipGroup: Int = 0b0 // 0000
    var currentPoseHasBeenPlayed: Bool = false
    let updateFingerTipsAfter: TimeInterval = 0.05
    var lastChangingUpdate: TimeInterval = Date().timeIntervalSince1970 - 5 // Be ready immediately
    
    private var rightHandSubscriber: AnyCancellable?
    private var leftHandSubscriber: AnyCancellable?
    
    let scaleDegreeForFingerTipGroup: [Int: UInt8] = [
        0b0001: 1,
        0b0011: 2,
        0b0111: 3,
        0b1111: 4,
        0b1000: 5,
        0b1100: 6,
        0b1110: 7,
    ]
    // These can be chosen automatically based on scale degree in key, but modified if right hand says so
    let chordTypeForFingerTipGroup: [Int: Chord] = [
        0b0001: .majorTriad,
        0b0011: .dominant7,
        0b0111: .major7,
        0b1111: .minorTriad,
        0b1000: .minor7,
        0b1100: .halfDim,
        0b1110: .fullDim,
    ]
    
    init(leftHand: HandPose, rightHand: HandPose) {
        pianoSampler.setup()
        
        self.leftHandSubscriber = leftHand.fingerTipGroupPublisher
            .sink(receiveValue: handleLeftHandUpdate)
        self.rightHandSubscriber = rightHand.fingerTipGroupPublisher
            .sink(receiveValue: handleRightHandUpdate)
    }
    
    // First check if hand pose is different; if so, update last update time and update last finger pose
    // Then check if hand pose is being held--check age of last update time
    // Then check if this change has been played yet
    func shouldPlayLeftHandPose(_ message: FingerTipsMessage) -> Bool {
        let now = Date().timeIntervalSince1970
        
        // Only play new sounds when left hand pose has stopped changing
        if self.leftHandFingerTipGroup != message.fingerTipGroup {
            self.currentPoseHasBeenPlayed = false
            self.lastChangingUpdate = now
            self.leftHandFingerTipGroup = message.fingerTipGroup
            return false
        }
        
        // Hand pose was changing but most recent change has not been held long enough to be registered
        if lastChangingUpdate > (now - updateFingerTipsAfter) {
            return false
        }
        
        // Only play each new change once
        if self.currentPoseHasBeenPlayed {
            return false
        }
        
        // Hand pose was changed but has not been changing; it is being held
        return true
    }
    
    func handleLeftHandUpdate(message: FingerTipsMessage) {
        // Update thumb location regardless of whether fingertip group changed
        self.leftHandThumbLocation = message.thumbLocation
        guard self.shouldPlayLeftHandPose(message) else { return }
        
        self.stopMusic()
        self.playMusic(for: message.fingerTipGroup, with: message.thumbLocation)
        self.currentPoseHasBeenPlayed = true
    }
    
    func handleRightHandUpdate(message: FingerTipsMessage) {
        guard self.rightHandFingerTipGroup != message.fingerTipGroup else { return }
        
        self.rightHandFingerTipGroup = message.fingerTipGroup
        // Right hand pose updates used to cause notes to be played, and it was kind of cool,
        // but harder to play. Maybe this could be a mode.
    }
    
    func setMusicalMode(to musicalMode: MusicalMode) {
        self.musicalMode = musicalMode
    }
    
    private func setCurrentChord(chordRoot: UInt8, chordType: Chord) {
        self.chordRoot = chordRoot
        self.chordType = chordType
        print("Set chordRoot: \(self.chordRoot) and chordType: \(self.chordType)")
    }
    
    func getNotesToPlay(for fingerTipGroup: Int) -> [UInt8]? {
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
        
        self.setCurrentChord(chordRoot: chordRoot, chordType: chordType)
        
        return getChord(root: chordRoot, tones: chordType.values)
    }
    
    func getVelocity(from thumbLocation: CGPoint?) -> UInt8 {
        guard let thumbLocation = thumbLocation else {
            return 77
        }
        return UInt8(thumbLocation.y * 50) + 50
    }
    
    func playMusic(for fingerTipGroup: Int, with thumbLocation: CGPoint? = nil) {
        guard let notes = getNotesToPlay(for: fingerTipGroup) else {
            return
        }
        
        let velocity = getVelocity(from: thumbLocation)
        
        if useInstrument == .sampler {
            pianoSampler.notesOn(notes: notes, velocity: velocity)
        } else if useInstrument == .synthesizer {
            polyphonicPlayer.noteOn(notes: notes)
        }
    }
    
    func stopMusic() {
        // would be more robust to have an ActiveInstrument or something?
        // but also would be harder to read?
        if useInstrument == .sampler {
            pianoSampler.notesOff()
        } else if useInstrument == .synthesizer {
            polyphonicPlayer.noteOff()
        }
    }
}
