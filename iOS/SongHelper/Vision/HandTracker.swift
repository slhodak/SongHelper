//
//  FrameManager.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import AVFoundation
import Vision


let FingerTips: [VNHumanHandPoseObservation.JointName] = [
    .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip
]

let ConfidenceThreshold: Float = 0.5


class HandTracker: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    static let shared = HandTracker()
    
    @Published var leftHand: HandPose = HandPose()
    @Published var rightHand: HandPose = HandPose()
    
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
                
                if handObservation.chirality == .left {
                    self.leftHand.setDetected(landmarks: landmarks, chirality: .left)
                } else if handObservation.chirality == .right {
                    self.rightHand.setDetected(landmarks: landmarks, chirality: .right)
                }
            }
        }
    }
    
    func resetHands() {
        DispatchQueue.main.async {
            self.leftHand.reset()
            self.rightHand.reset()
        }
    }
}


class HandPose {
    var isDetected: Bool = false
    var chirality: VNChirality = .unknown
    var fingerTips: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint?] = [
        .thumbTip: nil,
        .indexTip: nil,
        .middleTip: nil,
        .ringTip: nil,
        .littleTip: nil
    ]
    
    func reset() {
        self.isDetected = false
        self.fingerTips = [
            .thumbTip: nil,
            .indexTip: nil,
            .middleTip: nil,
            .ringTip: nil,
            .littleTip: nil
        ]
    }
    
    func setDetected(landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint], chirality: VNChirality) {
        self.isDetected = true
        
        for (jointName, point) in landmarks {
            if point.confidence > ConfidenceThreshold && FingerTips.contains(jointName) {
                self.fingerTips[jointName] = point
                self.chirality = chirality
            }
        }
    }
    
    func proximity(of fingerTip1: VNHumanHandPoseObservation.JointName, to fingerTip2: VNHumanHandPoseObservation.JointName) -> CGPoint? {
        guard let location1 = fingerTips[fingerTip1]??.location,
              let location2 = fingerTips[fingerTip1]??.location else {
            return nil
        }
        
        return CGPoint(x: location1.x - location2.x, y: location1.y - location2.y)
    }
}
