//
//  TempoIndicatorView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/25/24.
//

import Foundation
import SwiftUI


struct TempoIndicatorView: View {
    @State private var angle: Double = 90
    @Binding var beat: Int
    let beatsPerMeasure: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .opacity(0.2)
                .frame(width: 50, height: 50)
            
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(.blue)
                .offset(y: -15)
                .rotationEffect(.degrees(angle))
        }
        .onChange(of: beat) { newBeat in
            angle += Double(360 / beatsPerMeasure)
        }
    }
}


//struct TempoIndicatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        TempoIndicatorView()
//    }
//}
