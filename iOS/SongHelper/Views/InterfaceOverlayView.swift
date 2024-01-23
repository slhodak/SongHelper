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
    @State private var selectedKey: String = "C"
    @State private var metronomeTickIsOn: Bool = false
    @ObservedObject var handPoseMusicController: HandPoseMusicController
    @ObservedObject var metronome: Metronome
    @FocusState private var isBPMInputActive: Bool
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
                VStack(spacing: 0) {
                    HStack {
                        Text("Key: ")
                        Picker("KeyRoot", selection: $selectedKey) {
                            ForEach(MU.noteNames, id: \.self) { noteName in
                                Text(noteName)
                                    .foregroundColor(.black)
                                    .tag(noteName)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 50, height: 50)
                        .onChange(of: selectedKey) { newKey in
                            handPoseMusicController.updateKeyRoot(to: selectedKey)
                        }
                        
                        Spacer()
                        
                        Text("BPM: ")
                        Picker("BPM", selection: $metronome.bpm) {
                            ForEach((30...220).reversed(), id: \.self) { bpm in
                                Text("\(bpm)")
                                    .foregroundColor(.black)
                                    .tag(bpm)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 50)
                    }
                    .background(Color.white.opacity(0.3))
                    
                    HStack {
                        Text("Mode: ")
                        Toggle(modeIsMajor ? "Maj" : "min", isOn: $modeIsMajor)
                            .onChange(of: modeIsMajor) { newValue in
                                if newValue == true {
                                    handPoseMusicController.setMusicalMode(to: .major)
                                } else {
                                    handPoseMusicController.setMusicalMode(to: .minor)
                                }
                            }
                        
                        Spacer()
                        
                        Text("Tick: ")
                        Toggle(metronomeTickIsOn ? "On" : "Off", isOn: $metronomeTickIsOn)
                            .onChange(of: metronomeTickIsOn) { newValue in
                                if newValue == true {
                                    metronome.setTickIsOn(to: true)
                                } else {
                                    metronome.setTickIsOn(to: false)
                                }
                            }
                    }
                    .background(Color.white.opacity(0.3))
                }
            }
            .font(.title3)
            .foregroundStyle(.black)
            .padding(12)
        }
    }
}
