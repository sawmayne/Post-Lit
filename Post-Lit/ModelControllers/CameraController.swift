//
//  CameraController.swift
//  Post-Lit
//
//  Created by Sam on 10/31/18.
//  Copyright © 2018 SamWayne. All rights reserved.
//
//
//import UIKit
//import AVFoundation
//// Might need to conform to NSObject
//class CameraController {
//    
//    static let shared = CameraController()
//    
//    var captureSession: AVCaptureSession?
//
//    // statuses
//    var currentCameraPosition: CameraPosition?
//    var flashStatus: flashModes?    
//
//    // device vars
//    var frontCamera: AVCaptureDevice?
//    var rearCamera: AVCaptureDevice?
//    var microphone: AVCaptureDevice?
//    var flash = AVCaptureDevice.FlashMode.off
//
//    // device inputs
//    var frontCameraInput: AVCaptureDeviceInput?
//    var rearCameraInput: AVCaptureDeviceInput?
//    var microphoneInput: AVCaptureDeviceInput?
//
//    // outputs
//    var videoOutput: AVCaptureMovieFileOutput?
//    var previewLayer: AVCaptureVideoPreviewLayer?
//    
//}
//
//extension CameraController {
//    func prepareForSetup(completion: @escaping (Bool) -> Void) {
//        func createCaptureSession() {
//            self.captureSession = AVCaptureSession()
//            self.captureSession?.startRunning()
//        }
//        createCaptureSession()
//        
//        func configureCaptureDevice() {
//            let cameraDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTelephotoCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
//            let micDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: AVMediaType.audio, position: .unspecified)
//            self.microphone = micDiscovery.devices.first
//            
//            let cameras = cameraDiscovery.devices.compactMap{ $0 }
//            guard !cameras.isEmpty else { completion(false) ; return }
//            
//            for camera in cameras {
//                if camera.position == .front {
//                    self.frontCamera = camera
//                }
//                if camera.position == .back {
//                    self.rearCamera = camera
//                }
//            }
//        }
//        configureCaptureDevice()
//        func configureDeviceInputs() {
//            guard let captureSession = self.captureSession else { completion(false) ; return }
//            
//            if let rearCamera = self.rearCamera {
//                try? self.rearCameraInput = AVCaptureDeviceInput(device: rearCamera)
//                guard let rearCameraInput = self.rearCameraInput else { completion(false) ; return }
//                if captureSession.canAddInput(rearCameraInput){
//                    captureSession.addInput(rearCameraInput)
//                }
//                self.currentCameraPosition = .rear
//            }
//            if let frontCamera = self.frontCamera {
//                try? self.frontCameraInput = AVCaptureDeviceInput(device: frontCamera)
//                guard let frontCameraInput = self.frontCameraInput else { completion(false) ; return }
//                if captureSession.canAddInput(frontCameraInput) {
//                    captureSession.addInput(frontCameraInput)
//                }
//                self.currentCameraPosition = .front
//            }
//            if let microphone = self.microphone {
//                try? self.microphoneInput = AVCaptureDeviceInput(device: microphone)
//                guard let microphoneInput = self.microphoneInput else { completion(false) ; return }
//                if captureSession.canAddInput(microphoneInput) {
//                    captureSession.addInput(microphoneInput)
//                }
//            }
//        }
//        configureDeviceInputs()
//
//        func configureVideoOutput() {
//            guard let captureSession = self.captureSession else { completion(false) ; return }
//            self.videoOutput = AVCaptureMovieFileOutput()
//
//            guard let videoOutput = self.videoOutput else { completion(false) ; return }
//            guard let frontCameraInput = self.frontCameraInput else { completion(false) ; return }
//            guard let rearCameraInput = self.rearCameraInput else { completion(false) ; return }
//            guard let microphoneInput = self.microphoneInput else { completion(false) ; return }
//
//            let frontCameraPort = frontCameraInput.ports
//            let rearCameraPort = rearCameraInput.ports
//            let microphonePort = microphoneInput.ports
//
//            captureSession.addOutput(videoOutput)
//
//            let frontCameraConnection = AVCaptureConnection(inputPorts: frontCameraPort, output: videoOutput)
//            let rearCameraConnection = AVCaptureConnection(inputPorts: rearCameraPort, output: videoOutput)
//            let microphoneConnection = AVCaptureConnection(inputPorts: microphonePort, output: videoOutput)
//
//            // MARK: - Settings for output with the 3 necessary connections
//            videoOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecKey], for: frontCameraConnection)
//            videoOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecKey], for: microphoneConnection)
//            videoOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecKey], for: rearCameraConnection)
//
//            // MARK: - Adding connections to the capture session
//            captureSession.addConnection(frontCameraConnection)
//            captureSession.addConnection(rearCameraConnection)
//            captureSession.addConnection(microphoneConnection)
//
//            captureSession.commitConfiguration()
//        }
//        configureVideoOutput()
//        completion(true)
//    }
//    
//    func displayPreview(on view: UIView) {
//        guard let captureSession = self.captureSession else { return }
//        
//        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        self.previewLayer?.connection?.videoOrientation = .portrait
//        view.layer.insertSublayer(self.previewLayer!, at: 0)
//        self.previewLayer?.frame = view.frame
//    }
//    
//    func toggleFlash() {
//        guard var flashStatus = flashStatus else { return }
//        switch flashStatus {
//        case .off:
//            flashStatus = .on
//            flash = AVCaptureDevice.FlashMode.on
//        case .on:
//            flashStatus = .off
//            flash = AVCaptureDevice.FlashMode.off
//        }
//    }
//    
//    func switchCamera() {
//        guard var currentCameraPosition = currentCameraPosition,
//            let captureSession = self.captureSession,
//            captureSession.isRunning,
//            let frontCameraInput = frontCameraInput,
//            let rearCameraInput = rearCameraInput else { return }
//        captureSession.beginConfiguration()
//        switch currentCameraPosition {
//        case .front:
//            currentCameraPosition = .rear
//            captureSession.removeInput(frontCameraInput)
//            captureSession.addInput(rearCameraInput)
//        case .rear:
//            currentCameraPosition = .front
//            captureSession.removeInput(rearCameraInput)
//            captureSession.addInput(frontCameraInput)
//        }
//        captureSession.commitConfiguration()
//    }
//}
//
//extension CameraController {
//    
//    public enum CameraPosition {
//        case front
//        case rear
//    }
//    
//    public enum flashModes {
//        case off
//        case on
//    }
//}
