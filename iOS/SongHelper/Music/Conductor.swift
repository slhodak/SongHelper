//
//  Conductor.swift
//  SongHelper
//
//  Created by Sam Hodak on 1/17/24.
//

import Foundation
import AVFoundation


enum AudioRecorderState {
    case recordingIsQueued
    case recording
    case loopPlayback
    case off
}

class Conductor: ObservableObject {
    @Published var clickIsOn: Bool = false
    @Published var bpm: Int = 100 {
        didSet {
            stop()
            start()
        }
    }
    var timer: Timer?
    let handPoseMusicController: HandPoseMusicController
    let audioRecorder: AudioRecorder
    @Published var audioRecorderState: AudioRecorderState = .off
    var audioPlayerClick1: AVAudioPlayer?
    var audioPlayerClick234: AVAudioPlayer?
    let beatsPerMeasure: Int
    let patternResolution: Int
    @Published var tick: Int = 0 // ticks per measure = patternResolution
    @Published var beat: Int = 0
    @Published var pattern: [Bool] = Array(repeating: false, count: 16)
    let patternLength: Int = 16
    var onTickCallback: (() -> Void)?
    
    init(bpm: Int,
         patternResolution: Int,
         beatsPerMeasure: Int,
         handPoseMusicController: HandPoseMusicController,
         audioRecorder: AudioRecorder
    ) {
        self.bpm = bpm
        self.patternResolution = patternResolution
        self.beatsPerMeasure = beatsPerMeasure
        self.audioRecorder = audioRecorder
        self.handPoseMusicController = handPoseMusicController
        setupAudioPlayers()
        self.start()
    }
    
    private func setupAudioPlayers() {
        // To-do: Use a single sample file with both sounds
        guard let click1URL = Bundle.main.url(forResource: "click-1", withExtension: "mp3") else { return }
        guard let click234URL = Bundle.main.url(forResource: "click-234", withExtension: "mp3") else { return }
        
        do {
            audioPlayerClick1 = try AVAudioPlayer(contentsOf: click1URL)
            audioPlayerClick234 = try AVAudioPlayer(contentsOf: click234URL)
            audioPlayerClick1?.prepareToPlay()
            audioPlayerClick234?.prepareToPlay()
        } catch {
            print("Unable to load the click sound.")
        }
    }
    
    func setBPM(to bpm: Int) {
        self.stop()
        self.bpm = bpm
        self.start()
    }
    
    func getSecondsPerTick() -> TimeInterval {
        let ticksPerBeat = Double(patternResolution) / Double(beatsPerMeasure)
        let ticksPerMinute = Double(bpm) * ticksPerBeat
        return 60.0 / ticksPerMinute
    }
    
    func start() {
        timer?.invalidate() // Stops any existing timer
        timer = Timer.scheduledTimer(
            timeInterval: getSecondsPerTick(),
            target: self,
            selector: #selector(doTick),
            userInfo: nil, repeats: true
        )
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    @objc private func doTick() {
        incrementTick()
        if incrementBeat() && clickIsOn {
            playClick()
        }
        if pattern[tick] == true {
            handPoseMusicController.stopCurrentChord()
            handPoseMusicController.playCurrentChord()
        }
        if tick == 0 {
            switch audioRecorderState {
            case .recordingIsQueued:
                audioRecorder.startRecording()
                audioRecorderState = .recording
            case .loopPlayback:
                audioRecorder.playRecording()
            case .recording:
                audioRecorder.stopRecording()
                audioRecorderState = .off
            case .off:
                break
            }
        }
    }
    
    private func incrementTick() {
        tick = (tick + 1) % patternLength
    }
    
    private func incrementBeat() -> Bool {
        // Check that this tick is a beat's tick, not a subdivision
        guard tick % (patternResolution / beatsPerMeasure) == 0 else {
            return false
        }
        
        beat = (beat + 1) % beatsPerMeasure
        return true
    }
    
    private func playClick() {
        if beat == 0 {
            playClick(from: audioPlayerClick1)
        } else {
            playClick(from: audioPlayerClick234)
        }
    }
    
    private func playClick(from audioPlayer: AVAudioPlayer?) {
        // Avoid player being blocked by ongoing previous tick playback
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0 // Reset so it starts playing tick again from the start
        }
        audioPlayer?.play()
    }
    
    func loopPlayAudio() {
        if audioRecorderState != .loopPlayback {
            audioRecorderState = .loopPlayback
        } else {
            audioRecorderState = .off
        }
    }
    
    func queueRecording() {
        audioRecorderState = .recordingIsQueued
    }
    
    func stopAudioRecorder() {
        audioRecorderState = .off
        audioRecorder.stopPlaying()
        audioRecorder.stopRecording()
    }
}
