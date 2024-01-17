//
//  Chords.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation


enum Chord {
    case minorTriad
    case majorTriad
    case halfDim
    case major7
    case dominant7
    case minor7
    case fullDim
    case sus4
    
    var values: [UInt8] {
        switch self {
        case .minorTriad:
            return [0, 3, 7]
        case .majorTriad:
            return [0, 4, 7]
        case .halfDim:
            return [0, 3, 6]
        case .major7:
            return [0, 4, 7, 11]
        case .dominant7:
            return [0, 4, 7, 10]
        case .minor7:
            return [0, 3, 7, 10]
        case .fullDim:
            return [0, 3, 6, 9]
        case .sus4:
            return [0, 5, 7]
        }
    }
    
    var string: String {
        switch self {
        case .minorTriad:
            return "Min"
        case .majorTriad:
            return "Maj"
        case .halfDim:
            return "Half Dim"
        case .major7:
            return "Maj7"
        case .dominant7:
            return "Dominant 7"
        case .minor7:
            return "Min7"
        case .fullDim:
            return "Dim"
        case .sus4:
            return "sus4"
        }
    }
}
