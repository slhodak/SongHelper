//
//  CameraManager.swift
//  SongHelper
//
//  Created by Sam Hodak on 12/20/23.
//

import Foundation
import AVFoundation

class CameraManager: ObservableObject {
    
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    static let shared = CameraManager()
    
    @Published var error: CameraError?
    
    @Published var session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "com.samhodak.cameraSessionQ")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var status: Status = .unconfigured
    
    private init() {
        config()
    }
    
    private func config() {
        checkPermissions()
        sessionQueue.async {
            self.configCaptureSession()
            self.session.startRunning()
        }
    }
    
    private func setError(_ error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                    self.setError(.deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
            
        case .restricted:
            status = .unauthorized
            setError(.restrictedAuthorization)
            
        case .denied:
            status = .unauthorized
            setError(.deniedAuthorization)
            
        case .authorized:
            break
            
        @unknown default:
            status = .unauthorized
            setError(.unknownAuthorization)
        }
    }
    
    private func configCaptureSession() {
        guard status == .unconfigured else { return }
        
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // Set session preset
        session.sessionPreset = .hd1280x720
        
        // Prepare device as input
        let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                             for: .video,
                                             position: .front)
        
        guard let camera = device else {
            setError(.cameraUnavailable)
            status = .failed
            return
        }
        
        // Add input device to session
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                setError(.cannotAddInput)
                status = .failed
                return
            }
        } catch {
            setError(.createCaptureInput(error))
            status = .failed
            return
        }
        
        // Add output to session
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            // Set video output format type
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            // Force landscape video orientation
            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
        } else {
            setError(.cannotAddOutput)
            status = .failed
            return
        }
        
        status = .configured
    }
    
    func set(
        _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
}


enum CameraError: Error {
    case cameraUnavailable
    case cannotAddInput
    case cannotAddOutput
    case createCaptureInput(Error)
    case deniedAuthorization
    case restrictedAuthorization
    case unknownAuthorization
}

extension CameraError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .cameraUnavailable:
      return "Camera unavailable"
    case .cannotAddInput:
      return "Cannot add capture input to session"
    case .cannotAddOutput:
      return "Cannot add video output to session"
    case .createCaptureInput(let error):
      return "Creating capture input for camera: \(error.localizedDescription)"
    case .deniedAuthorization:
      return "Camera access denied"
    case .restrictedAuthorization:
      return "Attempting to access a restricted capture device"
    case .unknownAuthorization:
      return "Unknown authorization status for capture device"
    }
  }
}
