//
//  HandPose.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/8/24.
//

import Foundation
import Vision
import Combine


let FingerTips: [VNHumanHandPoseObservation.JointName] = [
    .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip
]

let ConfidenceThreshold: Float = 0.5

class HandPose: ObservableObject {
    var chirality: VNChirality = .unknown
    private var cancellable: AnyCancellable?
    
    @Published var isDetected: Bool = false
    @Published var fingerTips: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint?] = [
        .thumbTip: nil,
        .indexTip: nil,
        .middleTip: nil,
        .ringTip: nil,
        .littleTip: nil
    ]
    @Published var fingerTipsNearThumbGroup: Int = 0
    
    init(chirality: VNChirality, handTracker: HandTracker) {
        self.chirality = chirality
        self.cancellable = handTracker.handPosePublisher.sink(receiveValue: self.handleHandPoseMessage)
    }
    
    func handleHandPoseMessage(_ message: HandPoseMessage) {
       // discard a message for the other hand
       guard message.chirality == self.chirality else { return }
       
       // erase the hand data if the update is empty
       if message.landmarks.isEmpty {
           DispatchQueue.main.async {
               self.reset()
           }
           return
       }
       
       // the message is for this hand, so apply the fingertips
       DispatchQueue.main.async {
           self.setDetected(landmarks: message.landmarks)
           self.findFingertipsNearThumb()
       }
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
    
    func findFingertipsNearThumb() {
        for (joint, _) in self.fingerTips {
            if joint == .thumbTip { continue }
            
            guard let distanceToThumb = self.proximity(of: joint, to: .thumbTip) else { continue }
            
//            print("distanceToThumb: \(distanceToThumb)")
            if distanceToThumb < 0.15 {
                switch joint {
                    case .indexTip:
                        fingerTipsNearThumbGroup += 1000
                    case .middleTip:
                        fingerTipsNearThumbGroup += 100
                    case .ringTip:
                        fingerTipsNearThumbGroup += 10
                    case .littleTip:
                        fingerTipsNearThumbGroup += 1
                    default:
                        break
                }
            }
        }
//        print("fingerTipsNearThumbGroup: \(fingertipsNearThumbGroup)")
    }
    
    func proximity(of fingerTip1: VNHumanHandPoseObservation.JointName, to fingerTip2: VNHumanHandPoseObservation.JointName) -> Double? {
        guard let location1 = fingerTips[fingerTip1]??.location,
              let location2 = fingerTips[fingerTip2]??.location else {
            return nil
        }
        
        let distanceX = location1.x - location2.x
        let distanceY = location1.y - location2.y
        
        return sqrt(pow(distanceX, 2) + pow(distanceY, 2))
    }
}
