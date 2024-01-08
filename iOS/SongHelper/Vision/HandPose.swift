//
//  HandPose.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/8/24.
//

import Foundation
import Vision


class HandPose {
    var isDetected: Bool = false
    var chirality: VNChirality = .unknown
    var fingerTips: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint?] = [
        .thumbTip: nil,
        .indexTip: nil,
        .middleTip: nil,
        .ringTip: nil,
        .littleTip: nil
    ]
    
    init(chirality: VNChirality) {
        self.chirality = chirality
    }
    
    func reset() {
        self.isDetected = false
        self.fingerTips = [
            .thumbTip: nil,
            .indexTip: nil,
            .middleTip: nil,
            .ringTip: nil,
            .littleTip: nil
        ]
    }
    
    func setDetected(landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) {
        self.isDetected = true
        
        for (jointName, point) in landmarks {
            if point.confidence > ConfidenceThreshold && FingerTips.contains(jointName) {
                self.fingerTips[jointName] = point
            }
        }
    }
    
    func proximity(of fingerTip1: VNHumanHandPoseObservation.JointName, to fingerTip2: VNHumanHandPoseObservation.JointName) -> CGPoint? {
        guard let location1 = fingerTips[fingerTip1]??.location,
              let location2 = fingerTips[fingerTip1]??.location else {
            return nil
        }
        
        return CGPoint(x: location1.x - location2.x, y: location1.y - location2.y)
    }
}
