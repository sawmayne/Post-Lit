//
//  CameraController.swift
//  Post-Lit
//
//  Created by Sam on 10/31/18.
//  Copyright © 2018 SamWayne. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: NSObject {
    
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    // device vars
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var microphone: AVCaptureDevice?
    var flasheMode = AVCaptureDevice.FlashMode.off
    
    // device inputs
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var microphoneInput: AVCaptureDeviceInput?
    
    // outPuts
    var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
}

extension CameraController {
    func prepateForSetup(completion: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevice() {
            // TODO: - Might have to change this from muxed to audio + video
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInMicrophone], mediaType: AVMediaType.muxed, position: .unspecified)
            let cameras = session.devices.compactMap{ $0 }
            guard !cameras.isEmpty else { return }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                if camera.position == .back {
                    self.rearCamera = camera
                }
            }
        }
        func configureDeviceInputs() {
            guard let captureSession = self.captureSession else { return }
            
            if let rearCamera = self.rearCamera {
                try? self.rearCameraInput = AVCaptureDeviceInput(device: rearCamera)
                guard let rearCameraInput = self.rearCameraInput else { return }
                if captureSession.canAddInput(rearCameraInput){
                    captureSession.addInput(rearCameraInput)
                }
                self.currentCameraPosition = .rear
            }
            if let frontCamera = self.frontCamera {
                try? self.frontCameraInput = AVCaptureDeviceInput(device: frontCamera)
                guard let frontCameraInput = self.frontCameraInput else { return }
                if captureSession.canAddInput(frontCameraInput) {
                    captureSession.addInput(frontCameraInput)
                }
                self.currentCameraPosition = .front
            }
            if let microphone = self.microphone {
                try? self.microphoneInput = AVCaptureDeviceInput(device: microphone)
                guard let microphoneInput = self.microphoneInput else { return }
                if captureSession.canAddInput(microphoneInput) {
                    captureSession.addInput(microphoneInput)
                }
            }
        }
        func configureVideoOutput() {
            guard let captureSession = self.captureSession else { return }
            self.videoOutput = AVCaptureMovieFileOutput()
            
            guard let videoOutput = self.videoOutput else { return }
            guard let frontCameraInput = self.frontCameraInput else { return }
            guard let rearCameraInput = self.rearCameraInput else { return }
            guard let microphoneInput = self.microphoneInput else { return }
            
            let frontCameraPort = frontCameraInput.ports
            let rearCameraPort = rearCameraInput.ports
            let microphonePort = microphoneInput.ports
            
            let frontCameraConnection = AVCaptureConnection(inputPorts: frontCameraPort, output: videoOutput)
            let rearCameraConnection = AVCaptureConnection(inputPorts: rearCameraPort, output: videoOutput)
            let microphoneConnection = AVCaptureConnection(inputPorts: microphonePort, output: videoOutput)
            
            // MARK: - Settings for output with the 3 necessary connections
            videoOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecKey], for: frontCameraConnection)
            videoOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecKey], for: microphoneConnection)
            videoOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecKey], for: rearCameraConnection)
            
            // MARK: - Adding connections to the capture session
            captureSession.addConnection(frontCameraConnection)
            captureSession.addConnection(rearCameraConnection)
            captureSession.addConnection(microphoneConnection)
        }
    }
    
    func displayPreview(on view: UIView) {
        guard let captureSession = self.captureSession, captureSession.isRunning else { return }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    
    func switchCamera() {
        guard var currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning, let frontCameraInput = frontCameraInput, let rearCameraInput = rearCameraInput else { return }
        switch currentCameraPosition {
        case .front:
            currentCameraPosition = .rear
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(rearCameraInput)
        case .rear:
            currentCameraPosition = .front
            captureSession.removeInput(rearCameraInput)
            captureSession.addInput(frontCameraInput)
        }
        captureSession.commitConfiguration()
    }
}

extension CameraController {
    
    public enum CameraPosition {
        case front
        case rear
    }
}
