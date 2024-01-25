//
//  HandTrackingChordView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/25/24.
//

import Foundation
import SwiftUI


struct HandTrackingChordView: View {
    var handPoseMusicController: HandPoseMusicController
    var handTracker: HandTracker
    @ObservedObject var conductor: Conductor
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    var body: some View {
        ZStack {
            AVHandTrackingView(handTracker: handTracker, leftHand: leftHand, rightHand: rightHand)
            InterfaceOverlayView(handPoseMusicController: handPoseMusicController, conductor: conductor)
//            DebugView(leftHand: handTracker, rightHand: leftHand, handTracker: rightHand, handPoseMusicController: handPoseMusicController)
        }
        .navigationBarBackButtonHidden()
    }
}
