//
//  ContentView.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/9/23.
//

import SwiftUI
import AVKit


let videoOverlaySpace = "videoOverlaySpace"


struct ContentView: View {
    private var handPoseMusicController: HandPoseMusicController
    @ObservedObject var handPoseNavigationController: HandPoseNavigationController
    private var handTracker: HandTracker
    private var audioRecorder: AudioRecorder
    @ObservedObject var conductor: Conductor
    @ObservedObject var leftHand: HandPose
    @ObservedObject var rightHand: HandPose
    
    init() {
        let audioRecorder = AudioRecorder()
        let handTracker = HandTracker()
        let conductor = Conductor(bpm: 100, patternResolution: 8, beatsPerMeasure: 4)
        let leftHand = HandPose(chirality: .left, handTracker: handTracker)
        let rightHand = HandPose(chirality: .right, handTracker: handTracker)
        
        self.audioRecorder = audioRecorder
        self.handTracker = handTracker
        self.conductor = conductor
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.handPoseMusicController = HandPoseMusicController(conductor: conductor, leftHand: leftHand, rightHand: rightHand)
        self.handPoseNavigationController = HandPoseNavigationController(leftHand: leftHand, rightHand: rightHand)
    }
    
    var body: some View {
        GeometryReader { geo in
            let frameSize = CGSize(width: geo.size.height * (1920/1080), height: geo.size.height)
            
            ZStack {
                HStack {
                    Spacer()
                    ZStack {
                        if handPoseNavigationController.currentView == .chord {
                            AVCameraUIView(captureSession: CameraManager.shared.session)
                        }
                        
                        if handPoseNavigationController.navigationMenuIsOpen {
                            NavigationMenuView(handPoseNavigationController: handPoseNavigationController, frameSize: frameSize)
                        }
                        
                        HandPointsView(handTracker: handTracker, leftHand: leftHand, rightHand: rightHand, size: frameSize)
                    }
                    .frame(width: frameSize.width, height: frameSize.height)
                    .coordinateSpace(name: videoOverlaySpace)
                    .onAppear() {
                        leftHand.setViewBounds(to: frameSize)
                        rightHand.setViewBounds(to: frameSize)
                    }
                }
                
                if handPoseNavigationController.currentView == .chord {
                    // Eventually this view should show/hide things based on which view is present in the other part of the screen
                    // and not be an "overlay" view, but a sidebar/panel view
                    InterfaceOverlayView(handPoseMusicController: handPoseMusicController, conductor: conductor)
                }
                
                if handPoseNavigationController.currentView == .beat {
                    BeatSequenceView(conductor: conductor)
                }
                
                if handPoseNavigationController.currentView == .audio {
                    ZStack {
                        Text("Record Audio")
                        Button("Record", action: audioRecorder.startRecording)
                        Button("Play", action: audioRecorder.play)
                        Button("Stop", action: audioRecorder.stop)
                    }
                }
                
                TempoIndicatorView(beat: $conductor.beat,
                                   beatsPerMeasure: conductor.beatsPerMeasure)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 5)
            }
        }
    }
}

import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    let engine = AVAudioEngine()
    var recorder: AVAudioRecorder?
    let player = AVAudioPlayer()
    
    override init() {
        super.init()
        config()
    }
    
    private func config() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myAudioFile.mp4")
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100
        ]
        
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder!.delegate = self
            recorder!.isMeteringEnabled = true
            recorder!.prepareToRecord()
        } catch {
            recorder = nil
            print(error.localizedDescription)
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startRecording() {
        print("To start recording audio")
        guard let recorder = recorder,
              !recorder.isRecording else { return }
        
        AVAudioSession.sharedInstance().requestRecordPermission {
            [unowned self] granted in
            if granted {
                DispatchQueue.main.async {
                    self.configureAudioSession()
                    if let recorder = self.recorder {
                        recorder.record()
                    }
                }
            }
        }
    }
    
    func stopRecording() {
        print("To stop recording audio")
    }
    
    func stopPlayback() {
        print("To stop audio playback")
    }
    
    func play() {
        print("Playing audio")
    }
    
    func stop() {
        print("Stopping audio")
        guard let recorder = recorder else { return }
        
        if recorder.isRecording {
            stopRecording()
        } else {
            stopPlayback()
        }
    }
    
}
