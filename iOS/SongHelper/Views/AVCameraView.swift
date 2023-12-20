//
//  AVCameraView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation
import SwiftUI

struct AVCameraView: View {
    var body: some View {
        ZStack {
            CameraPreviewHolder(captureSession: CameraManager.shared.session)
                .ignoresSafeArea()
        }
    }
}

struct AVCameraView_Previews: PreviewProvider {
    static var previews: some View {
        AVCameraView()
    }
}
