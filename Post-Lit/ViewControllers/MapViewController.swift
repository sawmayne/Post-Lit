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
    
    static let shared = MapViewController() 
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    var landingPad: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestLocationAccess()
        setupMap()
        setupLocationSettings()
        setLocationOnMap()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if landingPad == true {
            print("success")
            dropPin(location: locationManager.location!)
        }
    }
    
    func setLocationOnMap() {
        guard let location = locationManager.location else { return }
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
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
    
//    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        guard let location = locationManager.location else { return }
//        let center = location.coordinate
//        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
//        let region = MKCoordinateRegion(center: center, span: span)
//        mapView.setRegion(region, animated: true)
//    }
    
    func setupLocationSettings() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 50
        
    }
    
    func dropPin(location: CLLocation) {
        
        var location = location
        guard let locationManagersLocation = locationManager.location else { return }
        location = locationManagersLocation
        
        let pin = MKPointAnnotation.init()
        pin.coordinate = location.coordinate
        print("dropped pin")
        
        mapView.addAnnotation(pin)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let image = #imageLiteral(resourceName: "LIT")
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        pinView.image = resizedImage
        return pinView
    }
}
