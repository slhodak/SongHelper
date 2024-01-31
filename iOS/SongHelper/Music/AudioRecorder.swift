//
//  AudioRecorder.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/26/24.
//

import Foundation
import AVFoundation
import Accelerate


class AudioRecorder: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate, ObservableObject {
    var audioEngine = AVAudioEngine()
    var audioPlayer: AVAudioPlayer?
    var recordURL: URL?
    @Published var detectedNote: String?
    
    override init() {
        super.init()
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setPreferredSampleRate(44100)
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
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat, block: analyzeInput)
        
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
    
    private func analyzeInput(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        guard let channelData = buffer.floatChannelData else {
            print("Float channel data not found")
            return
        }
        
        // Create pointers to arrays for the real and imaginary parts of the frequency domain
        var realp = [Float](repeating: 0, count: Int(buffer.frameLength))
        var imagp = [Float](repeating: 0, count: Int(buffer.frameLength))
        
        let realPointer = UnsafeMutablePointer<Float>.allocate(capacity: realp.count)
        let imagPointer = UnsafeMutablePointer<Float>.allocate(capacity: imagp.count)
        
        realPointer.initialize(from: &realp, count: realp.count)
        imagPointer.initialize(from: &imagp, count: imagp.count)
        
        // Create a Hanning window
        var window = [Float](repeating: 0, count: Int(buffer.frameLength))
        vDSP_hann_window(&window, vDSP_Length(buffer.frameLength), Int32(vDSP_HANN_NORM))
        vDSP_vmul(channelData.pointee, 1, window, 1, channelData.pointee, 1, vDSP_Length(Int(buffer.frameLength)))
        
        // Initizalize a split complex vector
        var output = DSPSplitComplex(realp: realPointer, imagp: imagPointer)
        
        // Copy audio data to the real part of the complex vector
        memcpy(output.realp, channelData[0], Int(buffer.frameLength) * MemoryLayout<Float>.size)
        
        let log2n = vDSP_Length(log2f(Float(buffer.frameLength)))
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        
        // Perform FFT
        vDSP_fft_zip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        guard let frequency = getDominantFrequency(from: buffer, realPointer: realPointer, imagPointer: imagPointer) else {
            print("Could not get dominant frequency from fft data")
            cleanupFFT(fftSetup: fftSetup!, realPointer: realPointer, imagPointer: imagPointer)
            return
        }
        
        print("Dominant frequency: \(frequency)")
        // Publish updates on main thread
        DispatchQueue.main.async {
            // Map frequency to musical note (implement this function based on your needs)
            self.detectedNote = MU.mapFrequencyToMusicalNote(frequency)
        }
        
        // Always call this to avoid memory leaks!
        cleanupFFT(fftSetup: fftSetup!, realPointer: realPointer, imagPointer: imagPointer)
    }
    
    // Get the frequency with the highest magnitude in the frequency-domain buffer
    private func getDominantFrequency(from buffer: AVAudioPCMBuffer, realPointer: UnsafeMutablePointer<Float>, imagPointer: UnsafeMutablePointer<Float>) -> Float? {
        var magnitudes = [Float](repeating: 0.0, count: Int(buffer.frameLength))
        for i in 0..<Int(buffer.frameLength / 2) {
            let real = realPointer[i]
            let imag = imagPointer[i]
            // To get the real magnitude, use sqrt(), but we only need the relative magnitude, so squaring is OK
            magnitudes[i] = sqrt(real * real + imag * imag)
        }
        
        guard let maxIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0) else { return nil }
        
        return Float(AVAudioSession.sharedInstance().sampleRate) / Float(buffer.frameLength) * Float(maxIndex)
    }
    
    private func cleanupFFT(fftSetup: FFTSetup, realPointer: UnsafeMutablePointer<Float>, imagPointer: UnsafeMutablePointer<Float>) {
        vDSP_destroy_fftsetup(fftSetup)
        // Must deallocate these after destroying fftsetup
        realPointer.deallocate()
        imagPointer.deallocate()
    }
    
}
