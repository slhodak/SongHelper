//
//  DebugView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/10/24.
//

import Foundation
import SwiftUI


// This is not working -- because these aren't being called repeatedly or triggering ui updates automatically?
struct DebugView: View {
    var leftHand: HandPose
    var rightHand: HandPose
    var handTracker: HandTracker
    var handPoseMusicController: HandPoseMusicController
    var handPoseNavigationController: HandPoseNavigationController
    
    var body: some View {
        VStack {
            Text(leftHand.stringifyRecentVNFingerTips())
                .foregroundStyle(.green)
            Text(leftHand.stringifySmoothedFingerTips())
                .foregroundStyle(.blue)
            Text(String(handPoseMusicController.keyRoot))
            
            Text(String(handPoseMusicController.leftHandFingerTipGroup, radix: 2))
            Text(String(handPoseMusicController.rightHandFingerTipGroup, radix: 2))
        }
    }
}
