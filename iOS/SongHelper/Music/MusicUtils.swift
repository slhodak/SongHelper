//
//  MusicUtils.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation


typealias MU = MusicUtils

enum MusicUtils {
    static let noteNames: [String] = ["A", "Bb", "B", "C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#"]
    
    
    static func getChord(root: UInt8, tones: [UInt8]) -> [UInt8] {
        return tones.map { root + $0 }
    }

    static func findChordRoot(keyRoot: UInt8, octave: UInt8, midiInterval: UInt8) -> UInt8 {
        return keyRoot + (12 * (octave - 1)) + midiInterval
    }

    // Converts a scale degree into a number of semitones given a musical mode
    // e.g. 3rd scale degree is 4 semitones above the root if the mode is major
    static func scaleDegreeToMidiInterval(musicalMode: MusicalMode, scaleDegree: UInt8) -> UInt8? {
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

    static func getRegularChordTypeFor(musicalMode: MusicalMode, scaleDegree: UInt8) -> Chord? {
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

    static func midiToLetter(midiNote: UInt8) -> String {
        let normalizedMidiNote = midiNote - 21      // A0 starts at 21
        let pitchClass = Int(normalizedMidiNote % 12)
        return noteNames[pitchClass]
    }
}
