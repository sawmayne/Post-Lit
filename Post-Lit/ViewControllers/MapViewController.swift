//
//  MapViewController.swift
//  Post-Lit
//
//  Created by Sam on 10/31/18.
//  Copyright © 2018 SamWayne. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationAccess()
        setupMap()
        setupLocationSettings()
    }
    
    func setLocationOnMap() {
        guard let location = locationManager.location else { return }
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func requestLocationAccess() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .denied || authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode.none
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        guard let location = locationManager.location else { return }
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func setupLocationSettings() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 50
    }
    
    @IBAction func DropPin(_ sender: Any) {
        guard let location = locationManager.location else { return }
        let pin = MKPointAnnotation.init()
        pin.coordinate = location.coordinate
        pin.title = "test"
        
        
        mapView.addAnnotation(pin)
    }
}
