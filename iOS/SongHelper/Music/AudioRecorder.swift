//
//  AudioRecorder.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/26/24.
//

import Foundation
import AVFoundation


class AudioRecorder: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate, ObservableObject {
    var audioEngine = AVAudioEngine()
    var audioPlayer: AVAudioPlayer?
    var recordURL: URL?
    let sampleRate = 44100.0
    var yinAlgo: YinAlgo?
    @Published var detectedNote: String?
    
    override init() {
        super.init()
        self.yinAlgo = YinAlgo(sampleRate: Float(sampleRate), bufferSize: 1024)
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setPreferredSampleRate(sampleRate)
            try audioSession.setCategory(.playAndRecord,
                                         mode: .default,
                                         options: [.defaultToSpeaker, .allowBluetoothA2DP, .allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session")
            print(error.localizedDescription)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func enableRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        
        if recordURL == nil {
            recordURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        }
        
        enableWriteAudio(node: inputNode, url: recordURL!, format: recordingFormat)
    }
    
    private func enableWriteAudio(node: AVAudioNode, url: URL, format: AVAudioFormat) {
        do {
            let audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                do {
                    try audioFile.write(from: buffer)
                } catch {
                    print("Error writing audio file")
                    print(error.localizedDescription)
                }
            }
        } catch {
            print("error creating audio file")
            print(error.localizedDescription)
        }
    }
    
    // Now is never called unless conductor.queueRecording is called first, but this is fragile
    func startRecording() {
        do {
            print("To start recording audio")
            try audioEngine.start()
        } catch {
            print("Error beginning audio recording")
            print(error.localizedDescription)
        }
    }
    
    func stopRecording() {
        print("Stopping recording audio")
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
    
    func startPitchDetection() {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat, block: detectPitch)
        
        do {
            print("Starting pitch detection")
            try audioEngine.start()
        } catch {
            print("Error starting pitch detection")
            print(error.localizedDescription)
        }
    }
    
    func stopPitchDetection() {
        print("Stopping pitch detection")
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        detectedNote = nil
    }
    
    func playRecording() {
        stopRecording()
        
        do {
            print("Playing recorded audio")
            guard let recordURL = recordURL else { return }
            
            audioPlayer = try AVAudioPlayer(contentsOf: recordURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("Error playing audio")
            print(error.localizedDescription)
        }
    }
    
    func stopPlaying() {
        print("Stopping playing recording")
        audioPlayer?.stop()
    }
    
    private func detectPitch(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        if let pitch = yinAlgo?.getPitch(buffer: buffer) {
            DispatchQueue.main.async {
                self.detectedNote = self.nearestNote(to: pitch)
            }
        } else {
            detectedNote = nil
        }
    }
    
    private func nearestNote(to pitch: Float) -> String? {
        let notesByPitch: [(Float, String)] = [
            (4186.01, "C8"),
            (3951.07, "B7"),
            (3729.31, "A#7/Bb7"),
            (3520.00, "A7"),
            (3322.44, "G#7/Ab7"),
            (3135.96, "G7"),
            (2959.96, "F#7/Gb7"),
            (2793.83, "F7"),
            (2637.02, "E7"),
            (2489.02, "D#7/Eb7"),
            (2349.32, "D7"),
            (2217.46, "C#7/Db7"),
            (2093.00, "C7"),
            (1975.53, "B6"),
            (1864.66, "A#6/Bb6"),
            (1760.00, "A6"),
            (1661.22, "G#6/Ab6"),
            (1567.98, "G6"),
            (1479.98, "F#6/Gb6"),
            (1396.91, "F6"),
            (1318.51, "E6"),
            (1244.51, "D#6/Eb6"),
            (1174.66, "D6"),
            (1108.73, "C#6/Db6"),
            (1046.50, "C6"),
            (987.77, "B5"),
            (932.33, "A#5/Bb5"),
            (880.00, "A5"),
            (830.61, "G#5/Ab5"),
            (783.99, "G5"),
            (739.99, "F#5/Gb5"),
            (698.46, "F5"),
            (659.26, "E5"),
            (622.25, "D#5/Eb5"),
            (587.33, "D5"),
            (554.37, "C#5/Db5"),
            (523.25, "C5"),
            (493.88, "B4"),
            (466.16, "A#4/Bb4"),
            (440.00, "A4"),
            (415.30, "G#4/Ab4"),
            (392.00, "G4"),
            (369.99, "F#4/Gb4"),
            (349.23, "F4"),
            (329.63, "E4"),
            (311.13, "D#4/Eb4"),
            (293.66, "D4"),
            (277.18, "C#4/Db4"),
            (261.63, "C4"),
            (246.94, "B3"),
            (233.08, "A#3/Bb3"),
            (220.00, "A3"),
            (207.65, "G#3/Ab3"),
            (196.00, "G3"),
            (185.00, "F#3/Gb3"),
            (174.61, "F3"),
            (164.81, "E3"),
            (155.56, "D#3/Eb3"),
            (146.83, "D3"),
            (138.59, "C#3/Db3"),
            (130.81, "C3"),
            (123.47, "B2"),
            (116.54, "A#2/Bb2"),
            (110.00, "A2"),
            (103.83, "G#2/Ab2"),
            (98.00, "G2"),
            (92.50, "F#2/Gb2"),
            (87.31, "F2"),
            (82.41, "E2"),
            (77.78, "D#2/Eb2"),
            (73.42, "D2"),
            (69.30, "C#2/Db2"),
            (65.41, "C2"),
            (61.74, "B1"),
            (58.27, "A#1/Bb1"),
            (55.00, "A1"),
            (51.91, "G#1/Ab1"),
            (49.00, "G1"),
            (46.25, "F#1/Gb1"),
            (43.65, "F1"),
            (41.20, "E1"),
            (38.89, "D#1/Eb1"),
            (36.71, "D1"),
            (34.65, "C#1/Db1"),
            (32.70, "C1"),
            (30.87, "B0"),
            (29.14, "A#0/Bb0"),
            (27.50, "A0")
        ]
        
        var i = 0
        for (frequency, note) in notesByPitch {
            // As soon as pitch is less than frequency
            if pitch > frequency {
                // see whether it's closest to the current or last pitch
                guard i > 0 && i < notesByPitch.count - 1  else { return nil }
                
                let (lastFrequency, _) = notesByPitch[i-1]
                let diffA = lastFrequency - pitch
                let diffB = pitch - frequency
                
                if diffA < diffB {
                    // because for some reason the returned pitch is always a semitone too low
                    guard i > 1 else { return nil }
                    
                    let (_, lastLastNote) = notesByPitch[i-2]
                    return lastLastNote
                } else {
                    // apparently almost never reached
                    return note
                }
            }
            i += 1
        }
        
        return nil
    }
}
