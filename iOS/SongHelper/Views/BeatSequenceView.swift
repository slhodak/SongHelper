//
//  BeatSequenceView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/24/24.
//

import Foundation
import SwiftUI


struct BeatSquare: View {
    var position: Int
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            self.isSelected.toggle()
        }) {
            Rectangle()
                .fill(isSelected ? Color.blue : Color.gray)
                .frame(width: 50, height: 50)
        }
    }
}

struct BeatSequenceView: View {
    @ObservedObject var conductor: Conductor
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: conductor.patternResolution)) {
            ForEach(0..<conductor.patternLength) { index in
                BeatSquare(position: index, isSelected: $conductor.pattern[index])
            }
        }
        .navigationBarBackButtonHidden()
    }
}
