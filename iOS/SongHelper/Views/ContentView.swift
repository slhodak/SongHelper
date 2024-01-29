//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AVKit


let videoOverlaySpace = "videoOverlaySpace"


struct ContentView: View {
    private var handPoseMusicController: HandPoseMusicController
    @ObservedObject var handPoseNavigationController: HandPoseNavigationController
    private var handTracker: HandTracker
    private var audioRecorder: AudioRecorder
    @ObservedObject var conductor: Conductor
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    init() {
        let audioRecorder = AudioRecorder()
        let handTracker = HandTracker()
        let leftHand = HandPose(chirality: .left, handTracker: handTracker)
        let rightHand = HandPose(chirality: .right, handTracker: handTracker)
        let handPoseMusicController = HandPoseMusicController(leftHand: leftHand, rightHand: rightHand)
        let conductor = Conductor(bpm: 100,
                                  patternResolution: 8,
                                  beatsPerMeasure: 4,
                                  handPoseMusicController: handPoseMusicController,
                                  audioRecorder: audioRecorder)
        
        self.audioRecorder = audioRecorder
        self.handTracker = handTracker
        self.conductor = conductor
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.handPoseMusicController = handPoseMusicController
        self.handPoseNavigationController = HandPoseNavigationController(leftHand: leftHand, rightHand: rightHand)
    }
    
    var body: some View {
        GeometryReader { geo in
            let frameSize = CGSize(width: geo.size.height * (1920/1080), height: geo.size.height)
            
            ZStack {
                HStack {
                    Spacer()
                    ZStack {
                        if handPoseNavigationController.currentView == .chord {
                            AVCameraUIView(captureSession: CameraManager.shared.session)
                        }
                        
                        if handPoseNavigationController.navigationMenuIsOpen {
                            NavigationMenuView(handPoseNavigationController: handPoseNavigationController, frameSize: frameSize)
                        }
                        
                        HandPointsView(handTracker: handTracker, leftHand: leftHand, rightHand: rightHand, size: frameSize)
                    }
                    .frame(width: frameSize.width, height: frameSize.height)
                    .coordinateSpace(name: videoOverlaySpace)
                    .onAppear() {
                        leftHand.setViewBounds(to: frameSize)
                        rightHand.setViewBounds(to: frameSize)
                    }
                }
                
                if handPoseNavigationController.currentView == .chord {
                    // Eventually this view should show/hide things based on which view is present in the other part of the screen
                    // and not be an "overlay" view, but a sidebar/panel view
                    InterfaceOverlayView(handPoseMusicController: handPoseMusicController, conductor: conductor)
                }
                
                if handPoseNavigationController.currentView == .beat {
                    BeatSequenceView(conductor: conductor)
                }
                
                if handPoseNavigationController.currentView == .audio {
                    AudioRecorderView(audioRecorder: audioRecorder, conductor: conductor)
                }
                
                TempoIndicatorView(tick: $conductor.tick,
                                   beat: $conductor.beat,
                                   recordingIsQueued: $conductor.recordingIsQueued,
                                   patternResolution: conductor.patternResolution,
                                   patternLength: conductor.patternLength,
                                   beatsPerMeasure: conductor.beatsPerMeasure)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 5)
            }
        }
    }
}
