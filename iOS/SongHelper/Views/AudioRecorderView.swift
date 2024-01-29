//
//  AudioRecorderView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/26/24.
//

import Foundation
import SwiftUI


struct AudioRecorderView: View {
    let audioRecorder: AudioRecorder
    @ObservedObject var conductor: Conductor
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: audioRecorder.startRecording) {
                    Image(systemName: "circle.fill").foregroundStyle(.red)
                }
                Button(action: conductor.stopAudioRecorder){
                    Image(systemName: "stop.fill").foregroundStyle(.black)
                }
                Button(action: audioRecorder.playRecording){
                    Image(systemName: "play.fill").foregroundStyle(.black)
                }
                Button(action: conductor.toggleLoopPlayAudio) {
                    Image(systemName: "arrow.clockwise").foregroundStyle(
                        conductor.loopPlayAudio ? .blue : .gray
                    )
                }
            }
            .font(.largeTitle)
        }
    }
}
