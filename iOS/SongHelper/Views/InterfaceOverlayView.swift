//
//  InterfaceOverlayView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/21/23.
//

import Foundation
import SwiftUI


struct InterfaceOverlayView: View {
    @State private var modeIsMajor: Bool = true
    @State private var metronomeTickIsOn: Bool = false
    @ObservedObject var handPoseMusicController: HandPoseMusicController
    @ObservedObject var metronome: Metronome
    var size: CGSize
    
    init(handPoseMusicController: HandPoseMusicController, metronome: Metronome, size: CGSize) {
        self.handPoseMusicController = handPoseMusicController
        self.metronome = metronome
        self.size = size
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .stroke(Color.blue.opacity(0.5),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 12]))
                    .frame(width: size.width - 1, height: size.height - 1)
            }
            
            VStack(spacing: 0) {
                Spacer()
                Text("Next: \(handPoseMusicController.getCurrentChord())")
                Spacer()
                VStack {
                    HStack {
                        Text("Mode: ")
                        Toggle(modeIsMajor ? "Major" : "minor", isOn: $modeIsMajor)
                            .onChange(of: modeIsMajor) { newValue in
                                if newValue == true {
                                    handPoseMusicController.setMusicalMode(to: .major)
                                } else {
                                    handPoseMusicController.setMusicalMode(to: .minor)
                                }
                            }
                    }
                    .background(Color.white.opacity(0.25))
                    
                    HStack {
                        Text("Metronome: ")
                        Toggle(metronomeTickIsOn ? "On" : "Off", isOn: $metronomeTickIsOn)
                            .onChange(of: metronomeTickIsOn) { newValue in
                                if newValue == true {
                                    metronome.setTickIsOn(to: true)
                                } else {
                                    metronome.setTickIsOn(to: false)
                                }
                            }
                    }
                    .background(Color.white.opacity(0.25))
                }
            }
            .font(.title3)
            .padding(12)
        }
    }
}
