//
//  CameraViewController.swift
//  Post-Lit
//
//  Created by Sam on 10/31/18.
//  Copyright © 2018 SamWayne. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    @IBOutlet weak var cameraView: UIView!
    
    static let shared = CameraViewController()
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var currentCameraDirection: AVCaptureDevice.Position?
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    var captureDevice : AVCaptureDevice?
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            print("whack couldnt finish recording \(error.localizedDescription)")
        } else {
            
            let videoRecorded = outputURL! as URL
            
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! ShowVideoViewController
        vc.videoURL = sender as? URL
    }
    
    @IBAction func switchCameraTapped(_ sender: Any) {
        
        var Currentdevice = activeInput.device
        captureSession.beginConfiguration()
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        guard let inputToRemove = try? AVCaptureDeviceInput(device: Currentdevice) else { return }
        guard let inputToAdd = try? AVCaptureDeviceInput(device: Currentdevice) else { return }
        
        if Currentdevice == backCamera {
            captureSession.removeInput(inputToRemove)
            Currentdevice = frontCamera
            captureSession.addInput(inputToAdd)
        }
        else {
            if Currentdevice == frontCamera {
                captureSession.removeInput(inputToRemove)
                Currentdevice = frontCamera
                captureSession.addInput(inputToAdd)
            }
        }
        captureSession.commitConfiguration()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        CameraController.shared.toggleFlash()
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        startRecording()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuth()
        
        // Do any additional setup after loading the view, typically from a nib.
        if setupSession() == true {
            setupPreview()
            startSession()
        } else {
            captureSession.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(cameraView)
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        self.captureDevice = camera
        
        do {
            guard let camera = camera else { return false }
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(.builtInMicrophone, for: AVMediaType.audio, position: .unspecified)
        
        do {
            guard let microphone = microphone else { return false }
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
        else {
            stopSession()
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
                self.previewLayer.removeFromSuperlayer()
                self.previewLayer = AVCaptureVideoPreviewLayer()
                
                if self.setupSession() == true {
                    self.setupPreview()
                    self.startSession()
                }
                
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        }
        
        return orientation
    }
    
    func startCapture() {
        
        startRecording()
        
    }
    
    func tempURL() -> URL? {
        
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: .video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            stopSession()
        }
    }
    
    func requestAuth() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: // The user has previously granted access to the camera.
            print("Authorized audio already")
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("authorized audio")
                }
            }
            
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            print("Authorized video already")
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Authorized video")
                }
            }
            
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        }
    }
}
