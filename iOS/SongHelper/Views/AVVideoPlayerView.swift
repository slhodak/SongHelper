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


struct CameraPreviewHolder: UIViewRepresentable {
    var captureSession: AVCaptureSession
    
    func makeUIView(context: UIViewRepresentableContext<CameraPreviewHolder>) -> CameraPreviewView {
        let cameraPreviewView = CameraPreviewView()
        cameraPreviewView.videoPreviewLayer.session = captureSession
        cameraPreviewView.videoPreviewLayer.videoGravity = .resizeAspect
        return cameraPreviewView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<CameraPreviewHolder>) {
    }
    
    typealias UIViewType = CameraPreviewView
}
