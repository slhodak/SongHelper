//
//  TempoIndicatorView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/25/24.
//

import Foundation
import SwiftUI


struct TempoIndicatorView: View {
    @State private var angle: Double = 0
    @State private var color: Color = .blue
    @Binding var tick: Int
    @Binding var beat: Int
    @Binding var audioRecorderState: AudioRecorderState
    let patternResolution: Int
    let patternLength: Int
    let beatsPerMeasure: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 1)
                .opacity(0.2)
                .frame(width: 50, height: 50)
            
            Circle()
                .frame(width: 18, height: 18)
                .foregroundStyle(color)
                .offset(y: -17)
                .rotationEffect(.degrees(angle))
            
            Text(String(calculateBeatsLeft())).foregroundStyle(
                audioRecorderState == .recordingIsQueued ? Color.red : Color.black.opacity(0.25)
            )
        }
        .onChange(of: beat) { newBeat in
            angle += Double(360 / beatsPerMeasure)
            if newBeat == 0 {
                color = .blue
            } else {
                color = .yellow
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 10)
    }
    
    private func calculateBeatsLeft() -> Int {
        // ticksLeft = 5, so beatsLeft = 2.5 aka 3
        // ticksLeft = 11, so beatsLeft = 5.5 aka 6
        let ticksLeft = patternLength - tick
        let ticksPerBeat = patternResolution / beatsPerMeasure
        var beatsLeft = Double(ticksLeft) / Double(ticksPerBeat)
        beatsLeft.round(.up)
        return Int(beatsLeft)
    }
}


//struct TempoIndicatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        TempoIndicatorView()
//    }
//}
