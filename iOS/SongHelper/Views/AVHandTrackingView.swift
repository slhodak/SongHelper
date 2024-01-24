//
//  AVHandTrackingView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/23/24.
//

import Foundation
import SwiftUI


struct AVHandTrackingView: View {
    var handTracker: HandTracker
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    var body: some View {
        // GeometryReader must surround the HStack to in order for the spacer to work
        GeometryReader { geo in
            let frameSize = CGSize(width: geo.size.height * (1920/1080), height: geo.size.height)
            
            HStack {
                Spacer() // Make video view hug the right edge
                ZStack {
                    AVCameraUIView(captureSession: CameraManager.shared.session)
                    HandPointsView(handTracker: handTracker, leftHand: leftHand, rightHand: rightHand, size: frameSize)
                }
                .frame(width: frameSize.width, height: frameSize.height)
            }
        }
    }
}
