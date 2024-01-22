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
                InterfaceOverlayView(handPoseMusicController: handPoseMusicController, size: videoSize)
//                Text("This way up")
//                DebugView(handTracker: handTracker, leftHand: leftHand, rightHand: rightHand, handPoseMusicController: handPoseMusicController)
            }
            .frame(width: videoSize.width, height: videoSize.height, alignment: .center)
        }
    }
}
