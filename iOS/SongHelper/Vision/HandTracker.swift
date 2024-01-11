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
                orientation: .left)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func handleHandPoseObservation(request: VNRequest, error: Error?) {
        guard let handPoseResults = request.results as? [VNHumanHandPoseObservation], handPoseResults.first != nil else {
            self.resetHand(.left)
            self.resetHand(.right)
            return
        }
        
        var handsSet: [VNChirality] = []
        
        for handObservation in handPoseResults {
            guard let landmarks = try? handObservation.recognizedPoints(.all) else { continue }
            
            handsSet.append(handObservation.chirality)
            let message = HandPoseMessage(chirality: handObservation.chirality, landmarks: landmarks)
            self.handPosePublisher.send(message)
        }
        
        if !handsSet.contains(.left) {
            self.resetHand(.left)
        }
        if !handsSet.contains(.right) {
            self.resetHand(.right)
        }
    }
    
    func resetHand(_ chirality: VNChirality) {
        self.handPosePublisher.send(HandPoseMessage(chirality: chirality, landmarks: [:]))
    }
}
