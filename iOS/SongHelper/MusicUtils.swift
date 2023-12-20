//
//  MusicUtils.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation


func getChord(root: Int, offset: Int, tones: [Int]) -> [Int] {
    return tones.map { root + offset + $0 }
}
