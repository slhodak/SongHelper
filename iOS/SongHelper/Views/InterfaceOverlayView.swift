//
//  InterfaceOverlayView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/21/23.
//

import Foundation
import SwiftUI


struct InterfaceOverlayView: View {
    @State private var selectedKey: String = "C"
    @ObservedObject var handPoseMusicController: HandPoseMusicController
    @ObservedObject var conductor: Conductor
    @FocusState private var isBPMInputActive: Bool
    
    init(handPoseMusicController: HandPoseMusicController, conductor: Conductor) {
        self.handPoseMusicController = handPoseMusicController
        self.conductor = conductor
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .trailing, spacing: 0) {
                Text(handPoseMusicController.getCurrentChord())
                    .padding(.bottom, 6)
                    .font(.title2)
                
                Toggle("Click", isOn: $conductor.clickIsOn)
                    .frame(maxWidth: 120)
                
                HStack {
                    Text("BPM")
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
                    Text("Key")
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
                
                Button(handPoseMusicController.musicalMode == .major ? "Major" : "minor", action: handPoseMusicController.toggleMusicalMode)
                    .foregroundStyle(.blue)
            }
            .frame(maxWidth: 140, maxHeight: .infinity)
            .padding([.leading, .trailing], 5)
            .background(.white)
            
            Spacer()
        }
        .font(.title3)
        .foregroundStyle(.black)
        .ignoresSafeArea(.container)
    }
}
