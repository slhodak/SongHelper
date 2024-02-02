//
//  Yin.swift
//  SongHelper
//
//  Created by Sam Hodak on 2/1/24.
//

import Foundation
import AVFoundation
import Accelerate


class YinAlgo {
    let sampleRate: Float
    let threshold: Float
    let bufferSize: Int
    var runs = 0
    
    init(sampleRate: Float, bufferSize: Int, threshold: Float = 0.15) {
        self.sampleRate = sampleRate
        self.threshold = threshold
        self.bufferSize = bufferSize
    }
    
    func getPitch(buffer: AVAudioPCMBuffer) -> Float? {
        guard let pointer = buffer.floatChannelData else {
            print("Float channel data not found")
            return nil
        }
        
        let elements: [Float] = Array.fromUnsafePointer(pointer.pointee, count: Int(buffer.frameLength))
        var diffElements = difference(buffer: elements)
        
        cumulativeDifference(yinBuffer: &diffElements)
        
        let tau = absoluteThreshold(yinBuffer: diffElements, withThreshold: threshold)
        var f0: Float
        
        if tau != 0 {
            let interpolatedTau = parabolicInterpolation(yinBuffer: diffElements, tau: tau)
            f0 = sampleRate / interpolatedTau
        } else {
            f0 = 0.0
        }
        
        return f0
    }
    
    private func difference(buffer: [Float]) -> [Float] {
        let bufferHalfCount = buffer.count / 2
        var resultBuffer = [Float](repeating: 0.0, count:bufferHalfCount)
        var tempBuffer = [Float](repeating: 0.0, count:bufferHalfCount)
        var tempBufferSq = [Float](repeating: 0.0, count:bufferHalfCount)
        let len = vDSP_Length(bufferHalfCount)
        var vSum: Float = 0.0
        
        for tau in 0 ..< bufferHalfCount {
            
            let bufferTau = buffer.withUnsafeBufferPointer({ $0 }).baseAddress!.advanced(by: tau)
            // do a diff of buffer with itself at tau offset
            vDSP_vsub(buffer, 1, bufferTau, 1, &tempBuffer, 1, len)
            // square each value of the diff vector
            vDSP_vsq(tempBuffer, 1, &tempBufferSq, 1, len)
            // sum the squared values into vSum
            vDSP_sve(tempBufferSq, 1, &vSum, len)
            // store that in the result buffer
            resultBuffer[tau] = vSum
        }
        
        return resultBuffer
    }
    
    private func cumulativeDifference(yinBuffer: inout [Float]) {
        yinBuffer[0] = 1.0
        
        var runningSum: Float = 0.0
        
        for tau in 1..<yinBuffer.count {
            runningSum += yinBuffer[tau]
            
            if runningSum == 0 {
                yinBuffer[tau] = 1
            } else {
                yinBuffer[tau] *= Float(tau) / runningSum
            }
        }
    }
    
    private func absoluteThreshold(yinBuffer: [Float], withThreshold threshold: Float) -> Int {
        var tau = 2
        var minTau = 0
        var minVal: Float = 1000.0
        
        while tau < yinBuffer.count {
            if yinBuffer[tau] < threshold {
                while (tau + 1) < yinBuffer.count && yinBuffer[tau + 1] < yinBuffer[tau] {
                    tau += 1
                }
                return tau
            } else {
                if yinBuffer[tau] < minVal {
                    minVal = yinBuffer[tau]
                    minTau = tau
                }
            }
            tau += 1
        }
        
        if minTau > 0 {
            return -minTau
        }
        
        return 0
    }
    
    private func parabolicInterpolation(yinBuffer: [Float], tau: Int) -> Float {
        guard tau != yinBuffer.count else {
            return Float(tau)
        }
        
        var betterTau: Float = 0.0
        
        if tau > 0 && tau < yinBuffer.count - 1 {
            let s0 = yinBuffer[tau - 1]
            let s1 = yinBuffer[tau]
            let s2 = yinBuffer[tau + 1]
            
            var adjustment = (s2 - s0) / (2.0 * (2.0 * s1 - s2 - s0))
            
            if abs(adjustment) > 1 {
                adjustment = 0
            }
            
            betterTau = Float(tau) + adjustment
        } else {
            betterTau = Float(tau)
        }
        
        return abs(betterTau)
    }
}


extension Array where Element:Comparable {
    static func fromUnsafePointer(_ data: UnsafePointer<Element>, count: Int) -> [Element] {
        let buffer = UnsafeBufferPointer(start: data, count: count)
        return Array(buffer)
    }
}
