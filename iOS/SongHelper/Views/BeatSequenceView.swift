//
//  BeatSequenceView.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/24/24.
//

import Foundation
import SwiftUI


struct BeatSquare: View {
    @State private var isSelected: Bool = false
    
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
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8)) {
            ForEach(0..<32) { _ in
                BeatSquare()
            }
        }
        .navigationBarBackButtonHidden()
    }
}
