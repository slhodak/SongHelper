//
//  Conductor.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/17/24.
//

import Foundation
import AVFoundation


class Conductor: ObservableObject {
    @Published var tickIsOn: Bool = false
    @Published var bpm: Int = 100 {
        didSet {
            stop()
            start()
        }
    }
    
    var timer: Timer?
    var audioPlayer: AVAudioPlayer?
    var beat: Int = 0
    var pattern: [Int] = Array(repeating: 0, count: 32)
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
            print("Unable to load the conductor sound file.")
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
            selector: #selector(tick),
            userInfo: nil, repeats: true
        )
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    @objc private func tick() {
        if tickIsOn {
            playTick()
        }
        playBeat()
    }
    
    private func playTick() {
        // Avoid player being blocked by ongoing previous tick playback
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0 // Reset so it starts playing tick again from the start
        }
        audioPlayer?.play()
    }
    
    private func playBeat() {
        beat = (beat + 1) % 32
        if let cb = onBeatCallback, pattern[beat] == 1 {
            cb()
        }
    }
    
    func setTickIsOn(to value: Bool) {
        tickIsOn = value
    }
}