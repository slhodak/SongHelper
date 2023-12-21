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
        ZStack {
            AVCameraView()
            HandPointsView(handTracker: handTracker, size: size)
            InterfaceOverlayView(size: size)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
