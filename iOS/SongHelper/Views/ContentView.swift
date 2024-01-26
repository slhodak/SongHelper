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
            .onAppear() {
                handPoseNavigationController.setViewBounds(to: geo.size)
            }
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


struct NavigationMenuView: View {
    // This View tells the HPNC where the options are located when it creates them
    var handPoseNavigationController: HandPoseNavigationController
    
    // To-Do: base the options locations on the location of the thumbs, like a pie menu
    var body: some View {
        GeometryReader { geo in
            let frameSize = CGSize(width: geo.size.height * (1920/1080),
                                   height: geo.size.height)
            
            HStack {
                Spacer()
                HStack {
                    ZStack {
                        Rectangle()
                            .frame(maxWidth: frameSize.width / 3)
                            .background(GeometryReader { patternOptionGeo in
                                Color.orange
                                    .onAppear() {
                                        handPoseNavigationController.setOptionSubviewFrame(for: "patternEditor", to: patternOptionGeo.frame(in: .named("videoOverlaySpace")))
                                    }
                            })
                            .opacity(0.2)
                        
                        Text("Pattern Editor")
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .frame(maxWidth: frameSize.width / 3)
                            .background(GeometryReader { chordOptionGeo in
                                Color.purple
                                    .onAppear() {
                                        handPoseNavigationController.setOptionSubviewFrame(for: "chordProgression", to: chordOptionGeo.frame(in: .named("videoOverlaySpace")))
                                    }
                            })
                            .opacity(0.2)
                        
                        Text("Chord Progression")
                    }
                }
                .frame(width: frameSize.width, height: frameSize.height)
                // To-Do: Find a less fragile way for this Menu to overlay the video
                .coordinateSpace(name: "videoOverlaySpace")
            }
        }
    }
}
