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
    
    @Published var handA: HandPose = HandPose()
    @Published var handB: HandPose = HandPose()
    
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
                
                if !self.handA.isDetected {
                    self.handA.setDetected(fingerTips: filteredLandmarks)
                } else {
                    self.handB.setDetected(fingerTips: filteredLandmarks)
                }
            }
        }
    }
    
    func getFilteredHandLandmarks(landmarks: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint]) -> [VNHumanHandPoseObservation.JointName : VNRecognizedPoint] {
        return Dictionary(uniqueKeysWithValues: landmarks.filter {
            jointName, recognizedPoint in
            return recognizedPoint.confidence > ConfidenceThreshold && FingerTips.contains(jointName)
        })
    }
    
    func resetHands() {
        DispatchQueue.main.async {
            self.handLandmarksA = [:]
            self.handLandmarksB = [:]
            self.handA.reset()
            self.handB.reset()
        }
    }
}


class HandPose {
    var isDetected: Bool = false
    var isInQuadrant: Quadrant?
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
    
    func setDetected(fingerTips: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) {
        self.isDetected = true
        
        for (jointName, point) in fingerTips {
            if point.confidence > ConfidenceThreshold && FingerTips.contains(jointName) {
                self.fingerTips[jointName] = point
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

enum Quadrant {
    case left
    case right
}
