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
    case none
}

class HandPoseNavigationController: ObservableObject {
    @Published var currentView: AppView = .chord
    @Published var navigationMenuIsOpen: Bool = false
    var viewBounds: CGSize?
    var optionSubviewFrames: [String: CGRect] = [:]
    private var selectingView: AppView = .none
    private var selectingViewSince: TimeInterval?
    private let selectViewAfter: TimeInterval = 0.5
    private let thumbsTouchingDistance: Double = 75
    private var leftHandFingerTipGroup: Int = 0b0
    private var rightHandFingerTipGroup: Int = 0b0
    private var leftHandThumbLocation: CGPoint?
    private var rightHandThumbLocation: CGPoint?
    private var leftHandSubscriber: AnyCancellable?
    private var rightHandSubscriber: AnyCancellable?
    private var ignoreHandPoseUntil: TimeInterval = Date().timeIntervalSince1970
    
    init(leftHand: HandPose, rightHand: HandPose) {
        self.leftHandSubscriber = leftHand.fingerTipGroupPublisher
            .sink(receiveValue: handleLeftHandUpdate)
        self.rightHandSubscriber = rightHand.fingerTipGroupPublisher
            .sink(receiveValue: handleRightHandUpdate)
    }
    
    private func handleLeftHandUpdate(message: FingerTipsMessage) {
        leftHandFingerTipGroup = message.fingerTipGroup
        leftHandThumbLocation = transformedThumbLocation(message.thumbLocation)
        
        if handsInNavigationMenuPose() {
            openNavigationMenu()
            if let frameName = thumbIsTouchingOptionSubviewFrame() {
                selectAppView(by: frameName)
            }
        } else {
            closeNavigationMenu()
        }
    }
    
    private func handleRightHandUpdate(message: FingerTipsMessage) {
        rightHandFingerTipGroup = message.fingerTipGroup
        rightHandThumbLocation = transformedThumbLocation(message.thumbLocation)
        
        if handsInNavigationMenuPose() {
            openNavigationMenu()
            if let frameName = thumbIsTouchingOptionSubviewFrame() {
                selectAppView(by: frameName)
            }
        } else {
            closeNavigationMenu()
        }
    }
    
    // To-Do: transform the fingertip points earlier -- probably in HandPose
    private func transformedThumbLocation(_ thumbLocation: CGPoint?) -> CGPoint? {
        guard let thumbLocation = thumbLocation,
              let viewBounds = viewBounds else { return nil }
        
        return CGPoint(
            x: (thumbLocation.x * viewBounds.width * -1) + viewBounds.width,
            y: (thumbLocation.y * viewBounds.height * -1) + viewBounds.height
        )
    }
    
    // The Navigation Menu Pose: both hands have fingers together and both thumbs are touching each other
    // bringing the grouped fingers over an option (for >0.5s) will select it
    private func handsInNavigationMenuPose() -> Bool {
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
        
        return VU.distance(from: leftHandThumbLocation,
                           to: rightHandThumbLocation) < thumbsTouchingDistance
    }
    
    // Change the current view if a selection is held for n seconds
    private func selectAppView(by name: String) {
        let now = Date().timeIntervalSince1970
        
        switch name {
        case "chordProgression":
            if selectingView != .chord {
                selectingViewSince = now
                selectingView = .chord
            }
        case "patternEditor":
            if selectingView != .beat {
                selectingViewSince = now
                selectingView = .beat
            }
        default:
            selectingView = .none
        }
        
        if selectingView != .none {
            updateCurrentView(to: selectingView, atTime: now)
        }
    }
    
    private func updateCurrentView(to: AppView, atTime now: TimeInterval) {
        guard let selectingViewSince = selectingViewSince else { return }
        
        if selectingViewSince <= now - selectViewAfter {
            currentView = selectingView
            selectingView = .none
        }
    }
    
    private func openNavigationMenu() {
        guard !navigationMenuIsOpen else { return }
        
        navigationMenuIsOpen = true
    }
    
    private func closeNavigationMenu() {
        guard navigationMenuIsOpen else { return }
        
        navigationMenuIsOpen = false
        resetOptionSubviewFrames()
    }
    
    // Menu Option Selection
    // Hit-Testing comparing thumb location and option view frames
    
    func setViewBounds(to size: CGSize) {
        viewBounds = size
    }
    
    private func resetOptionSubviewFrames() {
        optionSubviewFrames = [:]
    }
    
    func setOptionSubviewFrame(for name: String, to bounds: CGRect) {
        optionSubviewFrames[name] = bounds
    }
    
    private func thumbIsTouchingOptionSubviewFrame() -> String? {
        guard let leftHandThumbLocation = leftHandThumbLocation else { return nil }
        
        for (name, frame) in optionSubviewFrames {
            if frame.contains(leftHandThumbLocation) {
                return name
            }
        }
        
        return nil
    }
}
