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
        height: UIScreen.main.bounds.width * 1920 / 1080
    )
    
    var body: some View {
        ZStack {
            AVCameraView()
            HandPointsView(handTracker: handTracker, size: size)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

