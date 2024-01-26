//
//  HandPointsView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import SwiftUI
import Vision


struct HandPointsView: View {
    var handTracker: HandTracker
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    var size: CGSize
    
    var body: some View {
        ZStack {
            if !leftHand.fingerTips.isEmpty {
                drawHand(from: leftHand.fingerTips, color: .orange)
            }
            if !rightHand.fingerTips.isEmpty {
                drawHand(from: rightHand.fingerTips, color: .red)
            }
        }
    }
    
    private func drawHand(from landmarks: [VNHumanHandPoseObservation.JointName: CGPoint?], color: Color) -> some View {
        let points = pointsForHand(landmarks: landmarks)
        return Dot(points: points, size: size).fill(color)
    }
    
    private func pointsForHand(landmarks: [VNHumanHandPoseObservation.JointName: CGPoint?]) -> [CGPoint] {
        var points = [CGPoint]()
        for (_, point) in landmarks {
            guard let point = point else { continue }
            
            points.append(point)
        }
        return points
    }
}
