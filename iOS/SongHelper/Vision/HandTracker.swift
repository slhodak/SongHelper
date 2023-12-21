//
//  FrameManager.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import AVFoundation
import Vision


class HandTracker: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    static let shared = HandTracker()

    @Published var handLandmarksA: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint] = [:]
    @Published var handLandmarksB: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint] = [:]
    
    let vnSequenceHandler = VNSequenceRequestHandler()
    let videoOutputQueue = DispatchQueue(label: "com.samhodak.videoOutputQ",
                                         qos: .userInitiated,
                                         attributes: [],
                                         autoreleaseFrequency: .workItem)
    
    // Having FrameManager set itself as the buffer delegate seems like an antipattern
    private override init() {
        super.init()
        print("setting camera sample buffer delegate")
        CameraManager.shared.set(self, queue: videoOutputQueue)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        detectHands(sampleBuffer: sampleBuffer)
    }
    
    func detectHands(sampleBuffer: CMSampleBuffer) {
        let humanHandPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: detectedHandPose)
        humanHandPoseRequest.maximumHandCount = 2
        do {
            try vnSequenceHandler.perform(
                [humanHandPoseRequest],
                on: sampleBuffer,
                orientation: .up)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func detectedHandPose(request: VNRequest, error: Error?) {
        resetHands()
        guard let handPoseResults = request.results as? [VNHumanHandPoseObservation ], handPoseResults.first != nil else {
            return
        }
        
        DispatchQueue.main.async {
            for handObservation in handPoseResults {
                guard let landmarks = try? handObservation.recognizedPoints(.all) else { continue }
                
                let handLandmarks = Dictionary(uniqueKeysWithValues: landmarks.filter {
                    jointName, recognizedPoint in
                    return recognizedPoint.confidence > 0.5
                })
                
                if self.handLandmarksA.isEmpty {
                    self.handLandmarksA = handLandmarks
                } else {
                    self.handLandmarksB = handLandmarks
                }
            }
        }
    }
    
    func resetHands() {
        DispatchQueue.main.async {
            self.handLandmarksA = [:]
            self.handLandmarksB = [:]
        }
    }
}
