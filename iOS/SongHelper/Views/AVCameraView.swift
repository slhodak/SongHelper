//
//  AVVideoPlayerView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import SwiftUI
import AVKit

class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}


// Wraps a UIKit video view for display in SwiftUI
struct AVCameraUIView: UIViewRepresentable {
    let captureSession: AVCaptureSession
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<AVCameraUIView>) -> CameraPreviewView {
        let cameraPreviewView = CameraPreviewView()
        context.coordinator.previewLayer = cameraPreviewView.videoPreviewLayer
        context.coordinator.previewLayer!.session = captureSession
        context.coordinator.previewLayer!.videoGravity = .resizeAspect
        
        setVideoOrientation(previewLayer: context.coordinator.previewLayer!)
        
        print("made ui view")
        return cameraPreviewView
    }
    
    private func setVideoOrientation(previewLayer: AVCaptureVideoPreviewLayer) {
        if let connection = previewLayer.connection,
            connection.isVideoOrientationSupported {
            connection.videoOrientation = .landscapeLeft
        } else {
            print("Could not set video orientation to landscapeLeft")
        }
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<AVCameraUIView>) {
        print("ran ui view update")
    }
    
    class Coordinator {
        var parent: AVCameraUIView
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        init(_ parent: AVCameraUIView) {
            self.parent = parent
        }
    }
}
