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
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: frameSize.width / 4)
                    .background(GeometryReader { geo in
                        Color.black
                            .onAppear() {
                                handPoseNavigationController.setOptionSubviewFrame(for: .beat, to: geo.frame(in: .named(videoOverlaySpace)))
                            }
                    })
                    .opacity(0)
                    .border(.orange, width: 3)
                
                Text("Pattern\nEditor")
            }
            .background(.white)
            
            VStack {
                ZStack {
                    Rectangle()
                        .frame(maxHeight: frameSize.height / 4)
                        .background(GeometryReader { geo in
                            Color.black
                                .onAppear() {
                                    handPoseNavigationController.setOptionSubviewFrame(for: .audio, to: geo.frame(in: .named(videoOverlaySpace)))
                                }
                        })
                        .opacity(0)
                        .border(.green, width: 3)
                    
                    Text("Audio\nRecorder")
                }
                .background(.white)
                Spacer()
            }
            
            ZStack {
                Rectangle()
                    .frame(maxWidth: frameSize.width / 4)
                    .background(GeometryReader { geo in
                        Color.black
                            .onAppear() {
                                handPoseNavigationController.setOptionSubviewFrame(for: .chord, to: geo.frame(in: .named(videoOverlaySpace)))
                            }
                    })
                    .opacity(0.0)
                    .border(.purple, width: 3)
                
                Text("Chord\nPlayer")
            }
            .background(.white)
        }
        .font(.title)
    }
}
