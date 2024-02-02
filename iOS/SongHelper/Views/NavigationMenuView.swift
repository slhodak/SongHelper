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
        VStack {
            HStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack {
                        Rectangle()
                            .fill(.white)
                            .border(.orange, width: 3)
                            .onAppear() {
                                handPoseNavigationController.setOptionSubviewFrame(for: .beat, to: geo.frame(in: .named(videoOverlaySpace)))
                            }
                        Text("Pattern\nEditor")
                    }
                }
                
                GeometryReader { geo in
                    ZStack {
                        Rectangle()
                            .fill(.white)
                            .border(.green, width: 3)
                            .onAppear() {
                                handPoseNavigationController.setOptionSubviewFrame(for: .audio, to: geo.frame(in: .named(videoOverlaySpace)))
                            }
                        Text("Audio\nRecorder")
                    }
                }
                
                GeometryReader { geo in
                    ZStack {
                        Rectangle()
                            .fill(.white)
                            .border(.purple, width: 3)
                            .onAppear() {
                                handPoseNavigationController.setOptionSubviewFrame(for: .camera, to: geo.frame(in: .named(videoOverlaySpace)))
                            }
                        Text("Camera")
                    }
                }
            }
            .frame(maxHeight: frameSize.height / 4)
            .background(.white)
            
            Spacer()
        }
        .font(.title)
    }
}
