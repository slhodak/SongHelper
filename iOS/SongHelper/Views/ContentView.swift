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
            
            HStack {
                InterfaceSidebarView(handPoseMusicController: handPoseMusicController,
                                     conductor: conductor,
                                     audioRecorder: audioRecorder)
                
                ZStack {
                    switch handPoseNavigationController.currentView {
                    case .camera:
                        AVCameraUIView(captureSession: CameraManager.shared.session)
                    case .beat:
                        BeatSequenceView(conductor: conductor)
                    case .audio:
                        AudioRecorderView(audioRecorder: audioRecorder, conductor: conductor)
                    case .none:
                        EmptyView()
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
        }
        .ignoresSafeArea(.all)
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
