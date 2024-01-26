//
//  Messages.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/26/24.
//

import Foundation
import Vision


struct HandPoseMessage {
    var chirality: VNChirality
    var landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]
}

struct FingerTipsMessage {
    var fingerTipGroup: Int
    var thumbLocationVNPoint: CGPoint?
    var thumbLocationUIPoint: CGPoint?
}
