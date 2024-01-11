//
//  MusicUtils.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation


func getChord(root: Int, tones: [Int]) -> [Int] {
    return tones.map { root + $0 }
}

func getChordRoot(keyRoot: Int, octave: Int, midiInterval: Int) -> Int {
    return keyRoot + (12 * (octave - 1)) + midiInterval
}

// Converts a scale degree into a number of semitones given a musical mode
// e.g. 3rd scale degree is 4 semitones above the root if the mode is major
func scaleDegreeToMidiInterval(musicalMode: MusicalMode, scaleDegree: Int) -> Int? {
    if scaleDegree == 1 {
        if [.major, .minor].contains(musicalMode) {
            return 0
        }
    } else if scaleDegree == 2 {
        if [.major, .minor].contains(musicalMode) {
            return 2
        }
    } else if scaleDegree == 3 {
        if musicalMode == .major {
            return 4
        } else if musicalMode == .minor {
            return 3
        }
    } else if scaleDegree == 4 {
        if [.major, .minor].contains(musicalMode) {
            return 5
        }
    } else if scaleDegree == 5 {
        if [.major, .minor].contains(musicalMode) {
            return 7
        }
    } else if scaleDegree == 6 {
        if musicalMode == .major {
            return 9
        } else if musicalMode == .minor {
            return 8
        }
    } else if scaleDegree == 7 {
        if musicalMode == .major {
            return 11
        } else if musicalMode == .minor {
            return 10
        }
    }
    return nil
}

func getRegularChordTypeFor(musicalMode: MusicalMode, scaleDegree: Int) -> Chord? {
    if musicalMode == .major {
        if scaleDegree == 1 {
            return .majorTriad
        } else if scaleDegree == 2 {
            return .minorTriad
        } else if scaleDegree == 3 {
            return .minorTriad
        } else if scaleDegree == 4 {
            return .majorTriad
        } else if scaleDegree == 5 {
            return .majorTriad
        } else if scaleDegree == 6 {
            return .minorTriad
        } else if scaleDegree == 7 {
            return .halfDim
        }
    } else if musicalMode == .minor {
        if scaleDegree == 1 {
            return .minorTriad
        } else if scaleDegree == 2 {
            return .halfDim
        } else if scaleDegree == 3 {
            return .majorTriad
        } else if scaleDegree == 4 {
            return .minorTriad
        } else if scaleDegree == 5 {
            return .minorTriad
        } else if scaleDegree == 6 {
            return .majorTriad
        } else if scaleDegree == 7 {
            return .majorTriad
        }
    }
    return nil
}
