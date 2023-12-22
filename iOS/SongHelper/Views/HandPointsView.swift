//
//  HandPointsView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import SwiftUI
import Vision

struct HandPointsView: View {
    @ObservedObject var handTracker: HandTracker
    var size: CGSize
    
    var body: some View {
        ZStack {
            if !handTracker.handLandmarksA.isEmpty {
                drawHand(landmarks: handTracker.handLandmarksA, color: .orange)
            }
            if !handTracker.handLandmarksB.isEmpty {
                drawHand(landmarks: handTracker.handLandmarksB, color: .red)
            }
            
            Rectangle()
                .stroke(Color.yellow.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 14]))
                .frame(width: size.width - 1, height: size.height - 1)
        }
    }
    
    // For hand landmarks
    private func drawHand(landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint], color: Color) -> some View {
        let points = pointsForHand(landmarks: landmarks)
        return Dot(points: points, size: size, dotRadius: 0.02)
            .fill(color)
    }
    
    private func pointsForHand(landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> [CGPoint] {
        var points = [CGPoint]()
        for (_, point) in landmarks {
            points.append(point.location)
        }
        return points
    }
}
