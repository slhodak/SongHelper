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
    private var handTracker: HandTracker
    @ObservedObject var metronome: Metronome
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    init() {
        let handTracker = HandTracker()
        self.handTracker = handTracker
        
        let metronome = Metronome()
        let leftHand = HandPose(chirality: .left, handTracker: handTracker)
        let rightHand = HandPose(chirality: .right, handTracker: handTracker)
        
        self.metronome = metronome
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.handPoseMusicController = HandPoseMusicController(metronome: metronome, leftHand: leftHand, rightHand: rightHand)
    }
    
    var body: some View {
        ZStack {
            AVHandTrackingView(handTracker: handTracker, leftHand: leftHand, rightHand: rightHand)
            InterfaceOverlayView(handPoseMusicController: handPoseMusicController, metronome: metronome)
            
            //            DebugView(leftHand: handTracker, rightHand: leftHand, handTracker: rightHand, handPoseMusicController: handPoseMusicController)
        }
    }
}
