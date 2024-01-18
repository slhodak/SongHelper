//
//  Metronome.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/17/24.
//

import Foundation
import AVFoundation


class Metronome {
    var timer: Timer?
    var bpm: Int = 100
    var audioPlayer: AVAudioPlayer?
    var beat: Int = 0
    var pattern: [Int] = [1, 0, 1, 0]
    var onBeatCallback: (() -> Void)?
    
    init() {
        setupAudioPlayer()
    }
    
    func setOnBeatCallback(onBeatCallback: @escaping () -> Void) {
        self.onBeatCallback = onBeatCallback
    }
    
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "click1", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Unable to load the metronome sound file.")
        }
    }
    
    func setBPM(to bpm: Int) {
        self.stop()
        self.bpm = bpm
        self.start()
    }
    
    func start() {
        timer?.invalidate() // Stops any existing timer
        let timeInterval = 60.0 / Double(bpm)
        timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(playTick),
            userInfo: nil, repeats: true
        )
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    @objc private func playTick() {
        // Avoid player being blocked by ongoing previous tick playback
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0 // Reset so it starts playing tick again from the start
        }
        audioPlayer?.play()
        beat = (beat + 1) % 4
        if let cb = onBeatCallback, pattern[beat] == 1 {
            cb()
        }
    }
}
