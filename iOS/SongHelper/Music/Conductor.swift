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
    let beatsPerMeasure = 4
    var beat: Int = 0
    @Published var pattern: [Bool] = Array(repeating: false, count: 32)
    let patternResolution: Int = 8 // 8th notes
    let patternLength: Int = 32
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
            print("Unable to load the click sound.")
        }
    }
    
    func setBPM(to bpm: Int) {
        self.stop()
        self.bpm = bpm
        self.start()
    }
    
    func start() {
        timer?.invalidate() // Stops any existing timer
        let ticksPerBeat = Double(patternResolution) / Double(beatsPerMeasure)
        let ticksPerMinute = Double(bpm) * ticksPerBeat
        let secondsPerTick = 60.0 / ticksPerMinute
        timer = Timer.scheduledTimer(
            timeInterval: secondsPerTick,
            target: self,
            selector: #selector(tick),
            userInfo: nil, repeats: true
        )
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    @objc private func tick() {
        beat = (beat + 1) % patternLength
        let isQuarterNoteDownbeat = beat % (patternResolution / 4) == 0
        if tickIsOn && isQuarterNoteDownbeat {
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
        if let cb = onBeatCallback, pattern[beat] == true {
            cb()
        }
    }
    
    func setTickIsOn(to value: Bool) {
        tickIsOn = value
    }
}
