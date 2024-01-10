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
    
    var values: [Int] {
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
        }
    }
}
