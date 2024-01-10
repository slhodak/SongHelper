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

struct FingerTipGroupMessage {
    var fingerTipGroup: Int
}


class HandPoseMusicController: ObservableObject {
    @Published var currentRoot: Int = 60
    // To-do: set this somewhere else... a button? not necessary to control with fingers most of time
    var musicalMode: MusicalMode = .major
    
    // To-do: make "offset" a scale degree and later convert it into a number of half-steps
    //      offset is currently just a number of halfsteps (aka difference in midi note)
    let offsetForFingerTipGroup: [Int: Int] = [
        0b0001: 0,
        0b0010: 2,
        0b0011: 4,
        0b0100: 5,
        0b0101: 7,
        0b0110: 9,
        0b0111: 11,
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
    
    var leftHandFingerTipGroup: Int = 0b0 // 0000
    var rightHandFingerTipGroup: Int = 0b0 // 0000
    
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    private var rightHandSubscriber: AnyCancellable?
    private var leftHandSubscriber: AnyCancellable?
    
    init(leftHand: HandPose, rightHand: HandPose) {
        self.leftHandSubscriber = leftHand.fingerTipGroupPublisher.sink { message in
            // update if changed
            if self.leftHandFingerTipGroup != message.fingerTipGroup {
                self.leftHandFingerTipGroup = message.fingerTipGroup
                self.stopMusic()
                self.playMusic()
            }
        }
        
        self.rightHandSubscriber = rightHand.fingerTipGroupPublisher.sink { message in
            // update if changed
            if self.rightHandFingerTipGroup != message.fingerTipGroup {
                self.rightHandFingerTipGroup = message.fingerTipGroup
                self.stopMusic()
                self.playMusic()
            }
        }
    }
    
    func getNotesToPlay() -> [Int]? {
        //  Get the scale degree as a midi note/number of halftones from 0
        guard let offset = offsetForFingerTipGroup[leftHandFingerTipGroup] else {
            polyphonicPlayer.noteOff()
            return nil
        }
        
        // Convert the midi note into a scale degree (1 through 7)
        let scaleDegree = midiIntervalToScaleDegree(musicalMode: musicalMode, midiInterval: offset)
        guard let scaleDegree = scaleDegree else { return nil }
        
        // Get the chord type, either regular for scale or as modified by right hand if present
        var chordType = chordTypeForFingerTipGroup[rightHandFingerTipGroup]
        if chordType == nil {
            chordType = getRegularChordTypeFor(musicalMode: musicalMode, scaleDegree: scaleDegree)
        }
        guard let chordType = chordType else { return nil }
        
        return getChord(root: currentRoot, offset: offset, tones: chordType.values)
    }
    
    func playMusic() {
        guard let notes = getNotesToPlay() else {
            print("Could not determine notes to play")
            return
        }
        
        polyphonicPlayer.noteOn(notes: notes)
    }
    
    func stopMusic() {
        polyphonicPlayer.noteOff()
    }
}
