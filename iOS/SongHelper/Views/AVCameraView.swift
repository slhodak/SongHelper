//
//  AVCameraView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation
import SwiftUI

struct AVCameraView: View {
    var size: CGSize
    
    var body: some View {
        ZStack {
            CameraPreviewHolder(captureSession: CameraManager.shared.session)
            
            Rectangle()
                .stroke(Color.red.opacity(0.5),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 10]))
                .frame(width: size.width - 1, height: size.height - 1)
        }
    }
}
