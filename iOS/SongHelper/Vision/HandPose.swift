//
//  HandPose.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/8/24.
//

import Foundation
import Vision
import Combine
import DequeModule


let FingerTips: [VNHumanHandPoseObservation.JointName] = [
    .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip
]

let ConfidenceThreshold: Float = 0.5


struct HandPoseMessage {
    var chirality: VNChirality
    var landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]
}


class HandPose: ObservableObject {
    var chirality: VNChirality = .unknown
    private var cancellable: AnyCancellable?
    let fingerTipGroupPublisher = PassthroughSubject<FingerTipsMessage, Never>()
    
    var recentVNFingerTips: [VNHumanHandPoseObservation.JointName: Deque<CGPoint>] = [:]
    let requiredPointsCountForSmoothing: Int = 3
    @Published var fingerTips: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    
    init(chirality: VNChirality, handTracker: HandTracker) {
        self.reset()
        self.chirality = chirality
        self.cancellable = handTracker.handPosePublisher.sink(receiveValue: self.handleHandPoseMessage)
    }
    
    func handleHandPoseMessage(_ message: HandPoseMessage) {
        // Discard messages for the other hand
        guard message.chirality == self.chirality else { return }
        
        if message.landmarks.isEmpty {
            self.eraseHandDataOnMainThread()
        } else {
            self.updateHandDataOnMainThread(message)
        }
    }
    
    func eraseHandDataOnMainThread() {
        // Only erase if hand data exists
        guard !self.fingerTips.isEmpty else { return }
        
        DispatchQueue.main.async {
            self.reset()
            let message = FingerTipsMessage(fingerTipGroup: 0b0)
            self.fingerTipGroupPublisher.send(message)
        }
    }
    
    func updateHandDataOnMainThread(_ message: HandPoseMessage) {
        DispatchQueue.main.async {
            let fingerTips = self.processVNPoints(message.landmarks)
            self.fingerTips = fingerTips // Store so it can be published to SwiftUI
            let fingerTipsNearThumbGroup = self.findFingertipsNearThumb(fingerTips)
            
            let message = FingerTipsMessage(fingerTipGroup: fingerTipsNearThumbGroup)
            self.fingerTipGroupPublisher.send(message)
        }
    }
    
    func reset() {
        self.recentVNFingerTips = [:]
        self.fingerTips = [:]
    }
    
    func processVNPoints(_ vnPoints: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> [VNHumanHandPoseObservation.JointName: CGPoint] {
        var smoothedFingerTipPoints: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
        
        for (joint, vnFingerTipPoint) in vnPoints {
            if !FingerTips.contains(joint) { continue }
            if vnFingerTipPoint.confidence < ConfidenceThreshold { continue }
            
            let pointLocation = vnFingerTipPoint.location
            
            // initialize the joint recent fingertips array if it is nil
            if recentVNFingerTips[joint] == nil {
                recentVNFingerTips[joint] = [pointLocation]
            } else {
                recentVNFingerTips[joint]?.append(pointLocation)
            }
            
            if recentVNFingerTips[joint]!.count < requiredPointsCountForSmoothing {
                continue
            }
            
            if recentVNFingerTips[joint]!.count > requiredPointsCountForSmoothing {
                let excessPoints = recentVNFingerTips[joint]!.count - requiredPointsCountForSmoothing
                for _ in 1...excessPoints {
                    let _ = recentVNFingerTips[joint]!.popFirst()
                }
            }
            
            smoothedFingerTipPoints[joint] = self.smooth(points: recentVNFingerTips[joint]!)
        }
        
        return smoothedFingerTipPoints
    }
    
    func smooth(points: Deque<CGPoint>) -> CGPoint {
        var totalX: Double = 0
        var totalY: Double = 0
        for point in points {
            totalX += point.x
            totalY += point.y
        }
        let avgX = totalX / Double(points.count)
        let avgY = totalY / Double(points.count)
        
        return CGPoint(x: avgX, y: avgY)
    }
    
    func findFingertipsNearThumb(_ fingerTips: [VNHumanHandPoseObservation.JointName: CGPoint]) -> Int {
        var fingerTipsNearThumbGroup = 0b0
        
        guard let smoothedThumbTipPoint = fingerTips[.thumbTip] else {
            return fingerTipsNearThumbGroup
        }
        
        for (joint, smoothedFingerTipPoint) in fingerTips {
            if joint == .thumbTip { continue }
            
            guard let distanceToThumb = self.distance(
                from: smoothedFingerTipPoint, to: smoothedThumbTipPoint
            ) else { continue }
            
            if distanceToThumb < 0.125 {
                switch joint {
                case .indexTip:
                    fingerTipsNearThumbGroup += 0b1
                case .middleTip:
                    fingerTipsNearThumbGroup += 0b10
                case .ringTip:
                    fingerTipsNearThumbGroup += 0b100
                case .littleTip:
                    fingerTipsNearThumbGroup += 0b1000
                default:
                    break
                }
            }
        }
        
        return fingerTipsNearThumbGroup
    }
    
    func distance(from point1: CGPoint, to point2: CGPoint) -> Double? {
        let distanceX = point1.x - point2.x
        let distanceY = point1.y - point2.y
        
        return sqrt(pow(distanceX, 2) + pow(distanceY, 2))
    }
    
    func stringifyRecentVNFingerTips() -> String {
        return recentVNFingerTips.compactMap { (joint, points) -> String? in
            return "\(joint): \(points.count)"
        }.joined(separator: ", ")
    }
    
    func stringifySmoothedFingerTips() -> String {
        return fingerTips.compactMap { (joint, point) -> String? in
            return "\(joint): (\(point.x), \(point.y))"
        }.joined(separator: ", ")
    }
}
