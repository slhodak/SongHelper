//
//  MusicUtils.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation

// To-do: make "offset" a scale degree and later convert it into a number of half-steps
//      offset is currently just a number of halfsteps (aka difference in midi note)

func getChord(root: Int, offset: Int, tones: [Int]) -> [Int] {
    return tones.map { root + offset + $0 }
}

// Converts a midi interval into a scale degree, e.g. 0 is the 1st scale degree, 4 is the 3rd if
// the scale is major and 3 is the 3rd if the scale is minor
func midiIntervalToScaleDegree(musicalMode: MusicalMode, midiInterval: Int) -> Int? {
    if musicalMode == .major {
        if midiInterval == 0 {
            return 1
        } else if midiInterval == 2 {
            return 2
        } else if midiInterval == 4 {
            return 3
        } else if midiInterval == 5 {
            return 4
        } else if midiInterval == 7 {
            return 5
        } else if midiInterval == 9 {
            return 6
        } else if midiInterval == 11 {
            return 7
        }
    } else if musicalMode == .minor {
        if midiInterval == 0 {
            return 1
        } else if midiInterval == 2 {
            return 2
        } else if midiInterval == 3 {
            return 3
        } else if midiInterval == 5 {
            return 4
        } else if midiInterval == 6 {
            return 5
        } else if midiInterval == 8 {
            return 6
        } else if midiInterval == 10 {
            return 7
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
