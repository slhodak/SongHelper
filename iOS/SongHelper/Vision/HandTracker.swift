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
    
    let confidenceThreshold: Float = 0.5
    let fingerTips: [VNHumanHandPoseObservation.JointName] = [
        .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip
    ]
    
    @Published var handLandmarksA: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint] = [:]
    @Published var handLandmarksB: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint] = [:]
    
    let vnSequenceHandler = VNSequenceRequestHandler()
    let videoOutputQueue = DispatchQueue(label: "com.samhodak.videoOutputQ",
                                         qos: .userInitiated,
                                         attributes: [],
                                         autoreleaseFrequency: .workItem)
    
    // Having HandTracker set itself as the data output buffer delegate seems like an antipattern
    private override init() {
        super.init()
        print("setting camera sample buffer delegate")
        CameraManager.shared.set(self, queue: videoOutputQueue)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        makeHandPoseRequest(sampleBuffer: sampleBuffer)
    }
    
    func makeHandPoseRequest(sampleBuffer: CMSampleBuffer) {
        let humanHandPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: handleHandPoseObservation)
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
    
    func handleHandPoseObservation(request: VNRequest, error: Error?) {
        resetHands()
        guard let handPoseResults = request.results as? [VNHumanHandPoseObservation], handPoseResults.first != nil else {
            return
        }
        
        DispatchQueue.main.async {
            for handObservation in handPoseResults {
                guard let landmarks = try? handObservation.recognizedPoints(.all) else { continue }
                
                let filteredLandmarks = self.getFilteredHandLandmarks(landmarks: landmarks)
                
                if self.handLandmarksA.isEmpty {
                    self.handLandmarksA = filteredLandmarks
                } else {
                    self.handLandmarksB = filteredLandmarks
                }
            }
        }
    }
    
    func getFilteredHandLandmarks(landmarks: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint]) -> [VNHumanHandPoseObservation.JointName : VNRecognizedPoint] {
        return Dictionary(uniqueKeysWithValues: landmarks.filter {
            jointName, recognizedPoint in
            return recognizedPoint.confidence > self.confidenceThreshold && self.fingerTips.contains(jointName)
        })
    }
    
    func resetHands() {
        DispatchQueue.main.async {
            self.handLandmarksA = [:]
            self.handLandmarksB = [:]
        }
    }
}
