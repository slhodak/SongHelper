//
//  InterfaceOverlayView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/21/23.
//

import Foundation
import SwiftUI


struct InterfaceOverlayView: View {
    @ObservedObject var handPoseMusicController: HandPoseMusicController
    var size: CGSize
    var rectSize: CGSize
    
    init(handPoseMusicController: HandPoseMusicController, size: CGSize) {
        self.handPoseMusicController = handPoseMusicController
        self.size = size
        self.rectSize = CGSize(width: size.width - 2, height: (size.height/2) - 2)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
//                Rectangle()
//                    .fill(Color.purple.opacity(0.2))
//                    .frame(width: rectSize.width, height: rectSize.height)
//                
//                Rectangle()
//                    .fill(Color.green.opacity(0.2))
//                    .frame(width: rectSize.width, height: rectSize.height)
                Rectangle()
                    .stroke(Color.blue.opacity(0.5),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 12]))
                    .frame(width: size.width - 1, height: size.height - 1)
                
            }
            VStack(spacing: 0) {
                Text(handPoseMusicController.chordType.string)
                Spacer()
                Text(midiToLetter(midiNote: handPoseMusicController.chordRoot))
            }
            .font(.title)
        }
    }
}
