//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AVKit

let chordsByFingerTipGroup: [Int: String] = [
    0: "None",
    1000: "C",
    1100: "D",
    1110: "E",
    1111: "F"
]

struct ContentView: View {
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    var root = 60 // Middle C

    var handTracker: HandTracker
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    private let size: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height
    )
    
    init() {
        let handTracker = HandTracker()
        self.handTracker = handTracker
        self.leftHand = HandPose(chirality: .left, handTracker: handTracker)
        self.rightHand = HandPose(chirality: .right, handTracker: handTracker)
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
                    Text(chordsByFingerTipGroup[leftHand.fingerTipsNearThumbGroup] ?? "")
                    Text(String(leftHand.fingerTipsNearThumbGroup))
                }
            }
            .frame(width: videoSize.width, height: videoSize.height, alignment: .center)
        }
    }
}
