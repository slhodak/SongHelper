//
//  HandPoseNavigationController.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/25/24.
//

import Foundation
import Combine


enum AppView {
    case camera
    case beat
    case audio
    case none
}

class HandPoseNavigationController: ObservableObject {
    @Published var currentView: AppView = .camera
    @Published var navigationMenuIsOpen: Bool = false
    var optionSubviewFrames: [AppView: CGRect] = [:]
    private var selectingView: AppView = .none
    // is it restarting hand tracking after I select a thing?
    // it adds 5-10 "hands left nav menu pose" after redrawing UI without hands moving
    // hand tracking gets f'd by restarting UI
    // not a great use of time to try to make this smooth
    // add the audio recording
    private var handsLeftPose: Int = 0
    private var selectingViewSince: TimeInterval?
    private let selectViewAfter: TimeInterval = 0.5
    private var delayOpeningMenuAt: TimeInterval = Date().timeIntervalSince1970 - 3
    private let delayOpeningMenuFor: TimeInterval = 3
    private var blockOpeningMenu: Bool = false
    private let thumbsTouchingDistance: Double = 70 // in UI screen points
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
        leftHandThumbLocation = message.thumbLocationUIPoint
        updateNavigationMenu()
    }
    
    private func handleRightHandUpdate(message: FingerTipsMessage) {
        rightHandFingerTipGroup = message.fingerTipGroup
        rightHandThumbLocation = message.thumbLocationUIPoint
        updateNavigationMenu()
    }
    
    private func updateNavigationMenu() {
        if handsInNavigationMenuPose() {
            if shouldTryOpeningMenu() {
                openNavigationMenu()
                if let selectedAppView = thumbIsTouchingOptionSubviewFrame() {
                    if selectAppView(selectedAppView) {
                        closeNavigationMenu()
                        delayOpeningMenu()
                        blockOpeningMenu = true
                    }
                }
            }
        } else {
//            print("hands left nav menu pose \(handsLeftPose)")
//            handsLeftPose += 1
            closeNavigationMenu()
            blockOpeningMenu = false
        }
    }
    
    private func shouldTryOpeningMenu() -> Bool {
        return delayOpeningMenuAt + delayOpeningMenuFor < Date().timeIntervalSince1970 && !blockOpeningMenu
    }
    
    private func delayOpeningMenu() {
        delayOpeningMenuAt = Date().timeIntervalSince1970
    }
    
    // The Navigation Menu Pose: both hands have fingers together and both thumbs are touching each other
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
    // Returns whether currentView was changed
    private func selectAppView(_ appView: AppView) -> Bool {
        let now = Date().timeIntervalSince1970
        
        switch appView {
        case .camera:
            if selectingView != .camera {
                selectingViewSince = now
                selectingView = .camera
            }
        case .beat:
            if selectingView != .beat {
                selectingViewSince = now
                selectingView = .beat
            }
        case .audio:
            if selectingView != .audio {
                selectingViewSince = now
                selectingView = .audio
            }
        default:
            selectingView = .none
        }
        
        return updateCurrentView(atTime: now)
    }
    
    private func updateCurrentView(atTime now: TimeInterval) -> Bool {
        guard let selectingViewSince = selectingViewSince,
              selectingView != .none else { return false }
        
        if selectingViewSince <= now - selectViewAfter {
            currentView = selectingView
            selectingView = .none
            return true
        }
        
        return false
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
    // Hit-Testing comparing thumb location and option View frames
    
    private func resetOptionSubviewFrames() {
        optionSubviewFrames = [:]
    }
    
    func setOptionSubviewFrame(for name: AppView, to bounds: CGRect) {
        optionSubviewFrames[name] = bounds
    }
    
    private func thumbIsTouchingOptionSubviewFrame() -> AppView? {
        guard let leftHandThumbLocation = leftHandThumbLocation else { return nil }
        
        for (appView, frame) in optionSubviewFrames {
            if frame.contains(leftHandThumbLocation) {
                return appView
            }
        }
        
        return nil
    }
}
