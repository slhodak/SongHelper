//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AVKit


enum AppView {
    case chord
    case beat
}

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
        if handPoseNavigationController.currentView == .chord {
            HandTrackingChordView(
                handPoseMusicController: handPoseMusicController,
                handTracker: handTracker,
                conductor: conductor,
                leftHand: leftHand,
                rightHand: rightHand
            )
        } else if handPoseNavigationController.currentView == .beat {
            BeatSequenceView(conductor: conductor)
        }
    }
    
    private func isChordViewActive() -> Bool {
        return handPoseNavigationController.currentView == .chord
    }
    
    private func isBeatViewActive() -> Bool {
        return handPoseNavigationController.currentView == .beat
    }
}


import Combine

class HandPoseNavigationController: ObservableObject {
    @Published var currentView: AppView = .chord
    private var leftHandFingerTipGroup: Int = 0b0
    private var rightHandFingerTipGroup: Int = 0b0
    private var leftHandThumbLocation: CGPoint?
    private var rightHandThumbLocation: CGPoint?
    private var leftHandSubscriber: AnyCancellable?
    private var rightHandSubscriber: AnyCancellable?
    // Only handle a pose update every so often so user must hold pose
    // to-do this doesn't really make them hold the pose, make it so they do have to?
    private let updateHandlingDelay: TimeInterval = 0
    private var lastUpdateHandledAtTime: TimeInterval = Date().timeIntervalSince1970 - 2
    
    init(leftHand: HandPose, rightHand: HandPose) {
        self.leftHandSubscriber = leftHand.fingerTipGroupPublisher
            .sink(receiveValue: handleLeftHandUpdate)
        self.rightHandSubscriber = rightHand.fingerTipGroupPublisher
            .sink(receiveValue: handleRightHandUpdate)
    }
    
    private func handleLeftHandUpdate(message: FingerTipsMessage) {
        guard shouldHandleHandPoseUpdate() else { return }
        
        leftHandFingerTipGroup = message.fingerTipGroup
        leftHandThumbLocation = message.thumbLocation
        
        if handsInNavigationTogglePose() {
            toggleAppView()
        }
    }
    
    private func handleRightHandUpdate(message: FingerTipsMessage) {
        guard shouldHandleHandPoseUpdate() else { return }
        
        rightHandFingerTipGroup = message.fingerTipGroup
        rightHandThumbLocation = message.thumbLocation
        
        if handsInNavigationTogglePose() {
            toggleAppView()
        }
    }
    
    private func shouldHandleHandPoseUpdate() -> Bool {
        let now = Date().timeIntervalSince1970
        if lastUpdateHandledAtTime + updateHandlingDelay <= now {
            lastUpdateHandledAtTime = now
            return true
        }
        
        return false
    }
    
    // The Navigation Toggle Pose: both hands have fingers together and both thumbs are touching each other
    private func handsInNavigationTogglePose() -> Bool {
        return (
            leftHandFingerTipGroup == 0b0 &&
            rightHandFingerTipGroup == 0b0 &&
            thumbsAreTouching()
        )
    }
    
    private func thumbsAreTouching() -> Bool {
        guard let leftHandThumbLocation = leftHandThumbLocation,
              let rightHandThumbLocation = rightHandThumbLocation else {
            return false
        }
        
        return VU.distance(from: leftHandThumbLocation, to: rightHandThumbLocation) < 0.15
    }
    
    private func toggleAppView() {
        delayNextToggle()
        
        switch currentView {
        case .chord:
            currentView = .beat
        case .beat:
            currentView = .chord
        }
    }
    
    private func delayNextToggle() {
        lastUpdateHandledAtTime = Date().timeIntervalSince1970 + 3
    }
}

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
