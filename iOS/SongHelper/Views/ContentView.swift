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
            let frameSize = CGSize(
                width: geometry.size.height,
                height: geometry.size.height * (1920/1080))
            
            EmptyView()
                .onAppear {
                    print("Width: \(frameSize.width)")
                    print("Height: \(frameSize.height)")
                }
            
            ZStack {
                AVCameraView(size: frameSize)
                HandPointsView(handTracker: handTracker, size: frameSize)
                InterfaceOverlayView(size: frameSize)
                Text("This way up")
            }
            .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
            .rotationEffect(.degrees(90))
            .offset(x: frameSize.width / 2, y: -(frameSize.height / 5))
        }
    }
}
