//
//  AudioRecorder.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/26/24.
//

import Foundation
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
            recorder.stop()
        } else {
            stopPlayback()
        }
    }
}
