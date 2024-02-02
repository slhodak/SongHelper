//
//  AudioRecorderView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/26/24.
//

import Foundation
import SwiftUI


struct AudioRecorderView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var conductor: Conductor
    
    var body: some View {
        HStack {
            Button(action: conductor.queueRecording) {
                Image(systemName: "circle.fill").foregroundStyle(.red)
            }
            Button(action: conductor.stopAudioRecorder){
                Image(systemName: "stop.fill").foregroundStyle(.black)
            }
            Button(action: audioRecorder.playRecording){
                Image(systemName: "play.fill").foregroundStyle(.black)
            }
            Button(action: conductor.loopPlayAudio) {
                Image(systemName: "arrow.clockwise").foregroundStyle(
                    conductor.audioRecorderState == .loopPlayback ? .blue : .gray
                )
            }
        }
        .font(.largeTitle)
    }
}
