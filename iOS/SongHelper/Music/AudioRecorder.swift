//
//  AudioRecorder.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/26/24.
//

import Foundation
import AVFoundation


class AudioRecorder: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var recordEnabled: Bool = false
    
    override init() {
        super.init()
        configureAudioSession()
        configureAudioRecorder()
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default)
        try? audioSession.setActive(true)
    }
    
    private func configureAudioRecorder() {
        let recordURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 12000
        ]
        
        audioRecorder = try? AVAudioRecorder(url: recordURL, settings: settings)
        audioRecorder?.delegate = self
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        print("To start recording audio")
        audioRecorder?.record()
    }
    
    func stopRecording() {
        print("Stopping audio")
        audioRecorder?.stop()
    }
    
    func playRecording() {
        print("Playing audio")
        if let url = audioRecorder?.url {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        }
    }
}
