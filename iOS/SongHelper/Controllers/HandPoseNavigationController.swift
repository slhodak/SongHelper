//
//  HandPoseNavigationController.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/25/24.
//

import Foundation
import Combine


enum AppView {
    case chord
    case beat
}

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