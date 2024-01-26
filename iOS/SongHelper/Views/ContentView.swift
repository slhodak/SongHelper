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
        
        let conductor = Conductor(bpm: 100, patternResolution: 8, beatsPerMeasure: 4)
        let leftHand = HandPose(chirality: .left, handTracker: handTracker)
        let rightHand = HandPose(chirality: .right, handTracker: handTracker)
        
        self.conductor = conductor
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.handPoseMusicController = HandPoseMusicController(conductor: conductor, leftHand: leftHand, rightHand: rightHand)
        
        self.handPoseNavigationController = HandPoseNavigationController(leftHand: leftHand, rightHand: rightHand)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if handPoseNavigationController.currentView == .chord {
                    HandTrackingChordView(handPoseMusicController: handPoseMusicController,
                                          handTracker: handTracker,
                                          conductor: conductor,
                                          leftHand: leftHand,
                                          rightHand: rightHand)
                } else if handPoseNavigationController.currentView == .beat {
                    BeatSequenceView(conductor: conductor)
                }
                
                TempoIndicatorView(beat: $conductor.beat,
                                   beatsPerMeasure: conductor.beatsPerMeasure)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 5)
                
                if handPoseNavigationController.navigationMenuIsOpen {
                    NavigationMenuView(handPoseNavigationController: handPoseNavigationController)
                }
            }
        }
    }
}
