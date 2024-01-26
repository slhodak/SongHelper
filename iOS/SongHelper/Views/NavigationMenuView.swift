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
    
    // To-Do: base the options locations on the location of the thumbs, like a pie menu
    var body: some View {
        GeometryReader { geo in
            let frameSize = CGSize(width: geo.size.height * (1920/1080),
                                   height: geo.size.height)
            
            HStack {
                Spacer()
                HStack {
                    ZStack {
                        Rectangle()
                            .frame(maxWidth: frameSize.width / 3)
                            .background(GeometryReader { patternOptionGeo in
                                Color.orange
                                    .onAppear() {
                                        handPoseNavigationController.setOptionSubviewFrame(for: "patternEditor", to: patternOptionGeo.frame(in: .named("videoOverlaySpace")))
                                    }
                            })
                            .opacity(0.2)
                        
                        Text("Pattern Editor")
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .frame(maxWidth: frameSize.width / 3)
                            .background(GeometryReader { chordOptionGeo in
                                Color.purple
                                    .onAppear() {
                                        handPoseNavigationController.setOptionSubviewFrame(for: "chordProgression", to: chordOptionGeo.frame(in: .named("videoOverlaySpace")))
                                    }
                            })
                            .opacity(0.2)
                        
                        Text("Chord Progression")
                    }
                }
                .frame(width: frameSize.width, height: frameSize.height)
                // To-Do: Find a less fragile way for this Menu to overlay the video
                .coordinateSpace(name: "videoOverlaySpace")
            }
        }
    }
}

