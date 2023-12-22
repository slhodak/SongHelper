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
    
    private let size: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.height
    )
    
    var body: some View {
        GeometryReader { geometry in
            let geoSize = geometry.size
            let videoSize = CGSize(
                width: geoSize.width,
                height: geoSize.width * (1920/1080))
            
            ZStack {
                AVCameraView(size: videoSize)
                HandPointsView(handTracker: handTracker, size: videoSize)
                InterfaceOverlayView(size: videoSize)
                Text("This way up")
            }
            .frame(width: videoSize.width, height: videoSize.height, alignment: .center)
        }
    }
}
