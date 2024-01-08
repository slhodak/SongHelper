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
    var requests = 0
    
    @Published var leftHand: HandPose = HandPose(chirality: .left)
    @Published var rightHand: HandPose = HandPose(chirality: .right)
    
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
//        if requests % 100 == 0 {
//            print(sampleBuffer)
//        }
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
        requests += 1
//        if requests % 100 == 0 {
//            print(request)
//        }
        resetHands()
        guard let handPoseResults = request.results as? [VNHumanHandPoseObservation], handPoseResults.first != nil else {
            if requests % 100 == 0 {
                print(request.results!)
            }
            return
        }
        
        DispatchQueue.main.async {
            for handObservation in handPoseResults {
                guard let landmarks = try? handObservation.recognizedPoints(.all) else { continue }
                
                if handObservation.chirality == .left {
                    self.leftHand.setDetected(landmarks: landmarks)
                } else if handObservation.chirality == .right {
                    self.rightHand.setDetected(landmarks: landmarks)
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
