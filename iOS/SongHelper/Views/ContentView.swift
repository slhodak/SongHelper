//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AVKit


struct ContentView: View {
    private var handPoseMusicController: HandPoseMusicController
    @ObservedObject var handPoseNavigationController: HandPoseNavigationController
    private var handTracker: HandTracker
    @ObservedObject var conductor: Conductor
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    init() {
        let handTracker = HandTracker()
        self.handTracker = handTracker
        
        let conductor = Conductor()
        let leftHand = HandPose(chirality: .left, handTracker: handTracker)
        let rightHand = HandPose(chirality: .right, handTracker: handTracker)
        
        self.conductor = conductor
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.handPoseMusicController = HandPoseMusicController(conductor: conductor, leftHand: leftHand, rightHand: rightHand)
        
        self.handPoseNavigationController = HandPoseNavigationController(leftHand: leftHand, rightHand: rightHand)
    }
    
    var body: some View {
        // ZStack only so we can overlay the DebugView if we want to
        ZStack {
            if handPoseNavigationController.currentView == .chord {
                HandTrackingChordView(handPoseMusicController: handPoseMusicController,
                                      handTracker: handTracker,
                                      conductor: conductor,
                                      leftHand: leftHand,
                                      rightHand: rightHand
                )
            } else if handPoseNavigationController.currentView == .beat {
                BeatSequenceView(conductor: conductor)
            }
//            getDebugView()
        }
    }
    
    private func getDebugView() -> some View {
        return DebugView(leftHand: leftHand,
                         rightHand: rightHand,
                         handTracker: handTracker,
                         handPoseMusicController: handPoseMusicController,
                         handPoseNavigationController: handPoseNavigationController)
    }
    
    private func isChordViewActive() -> Bool {
        return handPoseNavigationController.currentView == .chord
    }
    
    private func isBeatViewActive() -> Bool {
        return handPoseNavigationController.currentView == .beat
    }
}
