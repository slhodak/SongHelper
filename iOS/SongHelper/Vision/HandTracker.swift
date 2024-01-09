//
//  FrameManager.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import AVFoundation
import Vision
import Combine


class HandTracker: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    var requests = 0
    
    var handPosePublisher = PassthroughSubject<HandPoseMessage, Never>()
    
    let vnSequenceHandler = VNSequenceRequestHandler()
    let videoOutputQueue = DispatchQueue(label: "com.samhodak.videoOutputQ",
                                         qos: .userInitiated,
                                         attributes: [],
                                         autoreleaseFrequency: .workItem)
    
    // Having HandTracker set itself as the data output buffer delegate seems like an antipattern
    override init() {
        super.init()
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
        requests += 1
        resetHands()
        guard let handPoseResults = request.results as? [VNHumanHandPoseObservation], handPoseResults.first != nil else {
            if requests % 50 == 0 {
                print("Did not detect anything in hand pose results")
            }
            return
        }
        
        for handObservation in handPoseResults {
            guard let landmarks = try? handObservation.recognizedPoints(.all) else { continue }

            if requests % 50 == 0 {
                print("Sending hand pose message")
            }
            let message = HandPoseMessage(chirality: handObservation.chirality, landmarks: landmarks)
            self.handPosePublisher.send(message)
        }
    }
    
    func resetHands() {
        self.handPosePublisher.send(HandPoseMessage(chirality: .left, landmarks: [:]))
        self.handPosePublisher.send(HandPoseMessage(chirality: .right, landmarks: [:]))
    }
}


struct HandPoseMessage {
    var chirality: VNChirality
    var landmarks: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]
}

