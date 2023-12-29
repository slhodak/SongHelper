//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AVKit


struct ContentView: View {
    private var polyphonicPlayer = PolyphonicPlayer(voices: 3)
    var root = 60 // Middle C
    @ObservedObject var handTracker = HandTracker.shared
    
    var body: some View {
        GeometryReader { geometry in
            let geoSize = geometry.size
            let videoSize = CGSize(
                width: geoSize.height,
                height: geoSize.height * (1920/1080))
            
            ZStack {
                AVCameraView(size: videoSize)
                HandPointsView(handTracker: handTracker, size: videoSize)
                InterfaceOverlayView(size: videoSize)
                Text("This way up")
            }
            .frame(width: videoSize.width, height: videoSize.height, alignment: .center)
            .rotationEffect(.degrees(90))
            .offset(x: videoSize.width / 2, y: -(videoSize.height / 5))
        }
    }
}
