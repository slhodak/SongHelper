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

enum SHInstrument {
    case sampler
    case synthesizer
}


class HandPoseMusicController: ObservableObject {
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    private var pianoSampler = PianoSampler()
    private var useInstrument: SHInstrument = .sampler
    private var conductor: Conductor
    
    @Published var keyRoot: UInt8 = 24 // C1
    var octave: UInt8 = 4
    @Published var musicalMode: MusicalMode = .major
    @Published var chordRoot: UInt8?
    @Published var chordType: Chord?
    
    var leftHandFingerTipGroup: Int = 0b0 // 0000
    var leftHandThumbLocation: CGPoint?
    var rightHandFingerTipGroup: Int = 0b0 // 0000
    var currentPoseHasBeenPlayed: Bool = false
    let updateFingerTipsAfter: TimeInterval = 0.05
    var lastChangingUpdate: TimeInterval = Date().timeIntervalSince1970 - 5 // Be ready immediately
    
    private var leftHandSubscriber: AnyCancellable?
    private var rightHandSubscriber: AnyCancellable?
    
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
        0b1110: .sus4,
    ]
    
    init(conductor: Conductor, leftHand: HandPose, rightHand: HandPose) {
        pianoSampler.setup()
        
        self.conductor = conductor
        self.leftHandSubscriber = leftHand.fingerTipGroupPublisher
            .sink(receiveValue: handleLeftHandUpdate)
        self.rightHandSubscriber = rightHand.fingerTipGroupPublisher
            .sink(receiveValue: handleRightHandUpdate)
        
        self.conductor.setOnTickCallback({
            self.stopCurrentChord()
            self.playCurrentChord()
        })
        self.conductor.start()
    }
    
    func handleLeftHandUpdate(message: FingerTipsMessage) {
        // Update thumb location regardless of whether fingertip group changed
        self.leftHandThumbLocation = message.thumbLocationVNPoint
        guard self.leftHandFingerTipGroup != message.fingerTipGroup else { return }
        
        self.leftHandFingerTipGroup = message.fingerTipGroup
        self.setCurrentChordRoot()
    }
    
    func handleRightHandUpdate(message: FingerTipsMessage) {
        guard self.rightHandFingerTipGroup != message.fingerTipGroup else { return }
        
        self.rightHandFingerTipGroup = message.fingerTipGroup
        self.setCurrentChordType()
    }
    
    func updateKeyRoot(to keyName: String) {
        guard let keyRootOffset = MU.noteNames.firstIndex(where: { $0 == keyName }) else {
            print("Error: Could not find KeyRoot index")
            return
        }
        
        self.keyRoot = UInt8(21 + keyRootOffset) // 21 is A0
    }
    
    func setMusicalMode(to musicalMode: MusicalMode) {
        self.musicalMode = musicalMode
    }
    
    func setCurrentChordType() {
        self.chordType = nil
        
        // Interpret the right hand fingertip grouping as a chord type, if it is present
        if let chordType = chordTypeForFingerTipGroup[rightHandFingerTipGroup] {
            self.chordType = chordType
            return
        }
        
        // Get the regular chord type for the scale degree
        guard let scaleDegree = scaleDegreeForFingerTipGroup[self.leftHandFingerTipGroup] else { return }
        
        self.chordType = MU.getRegularChordTypeFor(musicalMode: musicalMode, scaleDegree: scaleDegree)
    }
    
    private func setCurrentChordRoot() {
        self.chordRoot = nil
        
        // Interpret the fingertip grouping as a scale degree
        guard let scaleDegree = scaleDegreeForFingerTipGroup[leftHandFingerTipGroup] else { return }
        
        // Convert the scale degree into a number of semitones above the root
        guard let midiInterval = MU.scaleDegreeToMidiInterval(musicalMode: musicalMode, scaleDegree: scaleDegree) else { return }
        
        self.chordRoot = MU.findChordRoot(keyRoot: keyRoot, octave: octave, midiInterval: midiInterval)
        
        //  If not set by right hand, must set chord type by scale degree
        if rightHandFingerTipGroup == 0b0 {
            setCurrentChordType()
        }
    }
    
    func getCurrentChord() -> String {
        guard let chordRoot = chordRoot, let chordType = chordType else {
            return "none"
        }
        
        return "\(MU.midiToLetter(midiNote: chordRoot))\(chordType.string)"
    }
    
    func getVelocity(from thumbLocation: CGPoint?) -> UInt8 {
        guard let thumbLocation = thumbLocation else {
            return 77
        }
        return UInt8(thumbLocation.y * 50) + 50
    }
    
    func playCurrentChord() {
        guard let chordRoot = chordRoot,
              let chordType = chordType else { return }
        
        let notes = MU.getChord(root: chordRoot, tones: chordType.values)
        let velocity = getVelocity(from: leftHandThumbLocation)
        
        if useInstrument == .sampler {
            pianoSampler.notesOn(notes: notes, velocity: velocity)
        } else if useInstrument == .synthesizer {
            polyphonicPlayer.noteOn(notes: notes)
        }
    }
    
    func stopCurrentChord() {
        if useInstrument == .sampler {
            pianoSampler.notesOff()
        } else if useInstrument == .synthesizer {
            polyphonicPlayer.noteOff()
        }
    }
}
