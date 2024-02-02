//
//  InterfaceOverlayView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/21/23.
//

import Foundation
import SwiftUI


struct InterfaceSidebarView: View {
    @ObservedObject var handPoseMusicController: HandPoseMusicController
    @ObservedObject var conductor: Conductor
    @ObservedObject var audioRecorder: AudioRecorder
    @FocusState private var isBPMInputActive: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                MetronomeView(conductor: conductor)
                
                Text(handPoseMusicController.getCurrentChord())
                    .font(.title2)
                
                KeyView(handPoseMusicController: handPoseMusicController)
                
                PitchDetectorView(conductor: conductor, audioRecorder: audioRecorder)
            }
        }
        .padding([.leading], 6)
        .font(.title3)
        .background(.white)
        .foregroundStyle(.black)
    }
}


struct MetronomeView: View {
    @ObservedObject var conductor: Conductor
    
    var body: some View {
        HStack(spacing: 0) {
            TempoIndicatorView(tick: $conductor.tick,
                               beat: $conductor.beat,
                               clickIsOn: $conductor.clickIsOn,
                               audioRecorderState: $conductor.audioRecorderState,
                               patternResolution: conductor.patternResolution,
                               patternLength: conductor.patternLength,
                               beatsPerMeasure: conductor.beatsPerMeasure)
            
            Picker("BPM", selection: $conductor.bpm) {
                ForEach((30...220).reversed(), id: \.self) { bpm in
                    Text("\(bpm)")
                        .foregroundColor(.black)
                        .tag(bpm)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 80)
        }
    }
}


struct KeyView: View {
    @State private var selectedKey: String = "C"
    @ObservedObject var handPoseMusicController: HandPoseMusicController
    
    var body: some View {
        HStack(spacing: 0) {
            Picker("KeyRoot", selection: $selectedKey) {
                ForEach(MU.noteNames, id: \.self) { noteName in
                    Text(noteName)
                        .foregroundColor(.black)
                        .tag(noteName)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 80)
            .onChange(of: selectedKey) { newKey in
                handPoseMusicController.updateKeyRoot(to: selectedKey)
            }
            Button(handPoseMusicController.musicalMode == .major ? "Major" : "minor", action: handPoseMusicController.toggleMusicalMode)
                .foregroundStyle(.blue)
        }
    }
}


struct PitchDetectorView: View {
    @ObservedObject var conductor: Conductor
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        HStack {
            Button("Detect\nPitch", action: conductor.togglePitchDetection)
                .foregroundStyle(conductor.audioRecorderState == .pitchDetection ? .blue : .gray)
            Text("\u{266A}\(audioRecorder.detectedNote ?? "")")
                .frame(minWidth: 50)
        }
    }
}
