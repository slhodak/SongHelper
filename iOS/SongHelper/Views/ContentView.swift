//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AVKit


struct ContentView: View {
    private var root = 60 // Middle C

    private var handPoseMusicController: HandPoseMusicController
    private var handTracker: HandTracker
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    private let size: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height
    )
    
    init() {
        let handTracker = HandTracker()
        self.handTracker = handTracker
        
        let leftHand = HandPose(chirality: .left, handTracker: handTracker)
        let rightHand = HandPose(chirality: .right, handTracker: handTracker)
        
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.handPoseMusicController = HandPoseMusicController(leftHand: leftHand, rightHand: rightHand)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let geoSize = geometry.size
            let videoSize = CGSize(
                width: geoSize.width,
                height: geoSize.width * (1920/1080))
            
            ZStack {
                AVCameraView(size: videoSize)
                HandPointsView(handTracker: handTracker, leftHand: leftHand, rightHand: rightHand, size: videoSize)
                InterfaceOverlayView(size: videoSize)
//                Text("This way up")
                VStack {
                    Text(String(handPoseMusicController.currentRoot))
                    Text(String(handPoseMusicController.combinedFingerTipGroup, radix: 2))
                    Text(String(leftHand.fingerTipsNearThumbGroup))
                }
            }
            .frame(width: videoSize.width, height: videoSize.height, alignment: .center)
        }
    }
}

import Vision
import Combine


struct FingerTipGroupMessage {
    var fingerTipGroup: Int
}

class HandPoseMusicController: ObservableObject {
    let noteForFingerTipGroup: [Int: Int] = [
        0b00010000: 60, // middle C
        0b00100000: 62,
        0b00110000: 64,
        0b01000000: 65,
        0b01010000: 67,
        0b01100000: 69,
        0b01110000: 71,
    ]
    @Published var currentRoot: Int = 0
    
    var leftHandFingerTipGroup: Int = 0b0 // 0000
    var rightHandFingerTipGroup: Int = 0b0 // 0000
    @Published var combinedFingerTipGroup: Int = 0b0 // 0000 0000
    
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    private var rightHandSubscriber: AnyCancellable?
    private var leftHandSubscriber: AnyCancellable?
    
    init(leftHand: HandPose, rightHand: HandPose) {
        self.leftHandSubscriber = leftHand.fingerTipGroupPublisher.sink { message in
            self.leftHandFingerTipGroup = message.fingerTipGroup
            self.updateCombinedFingerTipGroup()
        }
        self.rightHandSubscriber = rightHand.fingerTipGroupPublisher.sink { message in
            self.rightHandFingerTipGroup = message.fingerTipGroup
            self.updateCombinedFingerTipGroup()
        }
    }
    
    func updateCombinedFingerTipGroup() {
        self.combinedFingerTipGroup = (self.leftHandFingerTipGroup << 4) | self.rightHandFingerTipGroup
    }
    
    func playMusic(for fingerTipsNearThumbGroup: Int) {
        guard let root = noteForFingerTipGroup[fingerTipsNearThumbGroup] else {
            polyphonicPlayer.noteOff()
            return
        }
        
        let notes = getChord(root: root, tones: Chord.majorTriad.values)
        polyphonicPlayer.noteOn(notes: notes)
    }
}
