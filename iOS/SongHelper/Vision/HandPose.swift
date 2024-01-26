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
let FingerTipProximityThreshold: Double = 60 // in UI screen points


class HandPose: ObservableObject {
    var chirality: VNChirality = .unknown
    var viewBounds: CGSize?
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
    
    func setViewBounds(to size: CGSize) {
        viewBounds = size
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
        // Only erase if hand data exists (makes this idempotent)
        guard !self.fingerTips.isEmpty else { return }
        
        DispatchQueue.main.async {
            self.reset()
            let message = FingerTipsMessage(fingerTipGroup: 0b0,
                                            thumbLocationVNPoint: nil,
                                            thumbLocationUIPoint: nil)
            
            self.fingerTipGroupPublisher.send(message)
        }
    }
    
    func updateHandDataOnMainThread(_ message: HandPoseMessage) {
        DispatchQueue.main.async {
            let (fingerTips, thumbLocationVNPoint, thumbLocationUIPoint) = self.processVNPoints(message.landmarks)
            self.fingerTips = fingerTips // Store so it can be published to SwiftUI
            let fingerTipsNearThumbGroup = self.findFingertipsNearThumb(fingerTips)
            
            let message = FingerTipsMessage(fingerTipGroup: fingerTipsNearThumbGroup,
                                            thumbLocationVNPoint: thumbLocationVNPoint,
                                            thumbLocationUIPoint: thumbLocationUIPoint)
            
            self.fingerTipGroupPublisher.send(message)
        }
    }
    
    func reset() {
        self.recentVNFingerTips = [:]
        self.fingerTips = [:]
    }
    
    func processVNPoints(_ vnPoints: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> ([VNHumanHandPoseObservation.JointName: CGPoint], CGPoint?, CGPoint?) {
        var fingerTipUIPoints: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
        var thumbLocationVNPoint: CGPoint? = nil
        var thumbLocationUIPoint: CGPoint? = nil
        
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
            
            let smoothedFingerTipPoint = self.smooth(points: recentVNFingerTips[joint]!)
            let transformedFingerTipPoint = self.transformFingerTip(
                point: smoothedFingerTipPoint
            )
            fingerTipUIPoints[joint] = transformedFingerTipPoint
            
            if joint == .thumbTip {
                thumbLocationVNPoint = smoothedFingerTipPoint
                thumbLocationUIPoint = transformedFingerTipPoint
            }
        }
        
        return (fingerTipUIPoints, thumbLocationVNPoint, thumbLocationUIPoint)
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
    
    // Convert point from VNPoint coordinates to UI coordinates within View
    private func transformFingerTip(point: CGPoint) -> CGPoint? {
        guard let viewBounds = viewBounds else { return nil }
    
        // Scale, mirror, and translate
        return CGPoint(
            x: (point.x * viewBounds.width * -1) + viewBounds.width,
            y: (point.y * viewBounds.height * -1) + viewBounds.height
        )
    }
    
    func findFingertipsNearThumb(_ fingerTips: [VNHumanHandPoseObservation.JointName: CGPoint]) -> Int {
        var fingerTipsNearThumbGroup = 0b0
        
        guard let thumbTipPoint = fingerTips[.thumbTip] else {
            return fingerTipsNearThumbGroup
        }
        
        for (joint, fingerTipPoint) in fingerTips {
            if joint == .thumbTip { continue }
            
            let distanceToThumb = VU.distance(from: fingerTipPoint, to: thumbTipPoint)
            
            if distanceToThumb > FingerTipProximityThreshold {
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
