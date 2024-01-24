//
//  VisionUtils.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/24/24.
//

import Foundation


typealias VU = VisionUtils

enum VisionUtils {
    static func distance(from point1: CGPoint, to point2: CGPoint) -> Double {
        let distanceX = point1.x - point2.x
        let distanceY = point1.y - point2.y
        
        return sqrt(pow(distanceX, 2) + pow(distanceY, 2))
    }
}
