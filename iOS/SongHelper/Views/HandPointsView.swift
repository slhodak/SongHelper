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
        let rightHandDetected = rightHand.isDetected
        let leftHandDetected = leftHand.isDetected
        ZStack {
            if leftHandDetected {
                drawHand(from: leftHand.fingerTips, color: .orange)
            }
            if rightHandDetected {
                drawHand(from: rightHand.fingerTips, color: .red)
            }
            
            Rectangle()
                .stroke(Color.yellow.opacity(0.5),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 14]))
                .frame(width: size.width - 1, height: size.height - 1)
        }
    }
    
    // For hand landmarks
    private func drawHand(from landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint?], color: Color) -> some View {
        let points = pointsForHand(landmarks: landmarks)
        return Dot(points: points, size: size, dotRadius: 0.02)
            .fill(color)
    }
    
    private func pointsForHand(landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint?]) -> [CGPoint] {
        var points = [CGPoint]()
        for (_, point) in landmarks {
            guard let point = point else { continue }
            
            points.append(point.location)
        }
        return points
    }
}
