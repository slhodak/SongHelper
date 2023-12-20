//
//  FrameManager.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import AVFoundation

class FrameManager: NSObject, ObservableObject {
    let handTracker = HandTracker()
    
    static let shared = FrameManager()

    let videoOutputQueue = DispatchQueue(label: "com.samhodak.videoOutputQ",
                                         qos: .userInitiated,
                                         attributes: [],
                                         autoreleaseFrequency: .workItem)
    
    private override init() {
        super.init()
        print("setting camera sample buffer delegate")
        CameraManager.shared.set(self, queue: videoOutputQueue)
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        handTracker.detectHands(sampleBuffer: sampleBuffer)
    }
}


// HandTracker.swift
import Vision

class HandTracker: NSObject, ObservableObject {
    var framesChecked = 0
    let vnSequenceHandler = VNSequenceRequestHandler()
    
    func detectHands(sampleBuffer: CMSampleBuffer) {
        let humanHandPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: detectedHandPose)
        humanHandPoseRequest.maximumHandCount = 2
        do {
            try vnSequenceHandler.perform(
                [humanHandPoseRequest],
                on: sampleBuffer,
                orientation: .right)
            framesChecked += 1
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func detectedHandPose(request: VNRequest, error: Error?) {
        if framesChecked % 1000 == 0 {
            print("Detected a hand")
        }
    }
}
