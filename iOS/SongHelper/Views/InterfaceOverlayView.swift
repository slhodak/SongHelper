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
    @ObservedObject var conductor: Conductor
    @FocusState private var isBPMInputActive: Bool
    
    init(handPoseMusicController: HandPoseMusicController, conductor: Conductor) {
        self.handPoseMusicController = handPoseMusicController
        self.conductor = conductor
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack {
                    Text("Current Cord")
                    Text(handPoseMusicController.getCurrentChord())
                }
                .font(.title2)
                
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
                }
                
                HStack {
                    Text("BPM: ")
                    Picker("BPM", selection: $conductor.bpm) {
                        ForEach((30...220).reversed(), id: \.self) { bpm in
                            Text("\(bpm)")
                                .foregroundColor(.black)
                                .tag(bpm)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 80, height: 50)
                }
                
                HStack {
                    Text("Mode: ")
                    Toggle(modeIsMajor ? "Maj" : "min", isOn: $modeIsMajor)
                        .onChange(of: modeIsMajor) { newValue in
                            handPoseMusicController.setMusicalMode(to: newValue == true ? .major : .minor)
                        }
                        .frame(maxWidth: 100)
                }
                
                HStack {
                    Toggle("Click", isOn: $metronomeTickIsOn)
                        .onChange(of: metronomeTickIsOn) { newValue in
                            conductor.setTickIsOn(to: newValue)
                        }
                        .frame(maxWidth: 120)
                }
            }
            .background(Color.white.opacity(0.3))
            Spacer()
        }
        .font(.title3)
        .foregroundStyle(.black)
        .ignoresSafeArea(.container)
    }
}
