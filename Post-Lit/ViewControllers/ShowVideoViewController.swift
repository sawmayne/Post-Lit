//
//  ShowVideoViewController.swift
//  Post-Lit
//
//  Created by Sam on 11/5/18.
//  Copyright © 2018 SamWayne. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import FirebaseStorage
import FirebaseFirestore

class ShowVideoViewController: UIViewController, CLLocationManagerDelegate {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    let locationManager = CLLocationManager()
    var videoURL: URL!
    //connect this to your uiview in storyboard
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .denied || authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "toMapVC", sender: self)
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination == MapViewController() {
            let videoAsData = try? Data(contentsOf: videoURL)
            
            MapViewController.shared.landingPad = true
        }
        
    }
}
