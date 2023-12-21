//
//  InterfaceOverlayView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/21/23.
//

import Foundation
import SwiftUI


struct InterfaceOverlayView: View {
    var size: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: size.width, height: size.height / 2)
            
            Rectangle()
                .fill(Color.green.opacity(0.2))
                .frame(width: size.width, height: size.height / 2)
        }
    }
}
