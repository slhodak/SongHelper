//
//  NavigationMenuView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/25/24.
//

import Foundation
import SwiftUI


struct NavigationMenuView: View {
    // This View tells the HPNC where the options are located when it creates them
    var handPoseNavigationController: HandPoseNavigationController
    var frameSize: CGSize
    
    // To-Do: base the options locations on the location of the thumbs, like a pie menu
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: frameSize.width / 4)
                    .background(GeometryReader { geo in
                        Color.orange
                            .onAppear() {
                                handPoseNavigationController.setOptionSubviewFrame(for: .beat, to: geo.frame(in: .named(videoOverlaySpace)))
                            }
                    })
                    .opacity(0.2)
                
                Text("Pattern\nEditor")
            }
            
            VStack {
                ZStack {
                    Rectangle()
                        .frame(maxHeight: frameSize.height / 4)
                        .background(GeometryReader { geo in
                            Color.green
                                .onAppear() {
                                    handPoseNavigationController.setOptionSubviewFrame(for: .audio, to: geo.frame(in: .named(videoOverlaySpace)))
                                }
                        })
                        .opacity(0.2)
                    
                    Text("Audio\nRecorder")
                }
                Spacer()
            }
            
            ZStack {
                Rectangle()
                    .frame(maxWidth: frameSize.width / 4)
                    .background(GeometryReader { geo in
                        Color.purple
                            .onAppear() {
                                handPoseNavigationController.setOptionSubviewFrame(for: .chord, to: geo.frame(in: .named(videoOverlaySpace)))
                            }
                    })
                    .opacity(0.2)
                
                Text("Chord\nPlayer")
            }
        }
        .font(.title)
    }
}
