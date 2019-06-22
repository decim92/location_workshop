//
//  ViewController.swift
//  Location Workshop
//
//  Created by Douglas on 6/15/19.
//  Copyright © 2019 Douglas. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationInteractor: LocationInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureInteractor()
        locationInteractor.requestDeviceLocation()
    }
    
    func configureInteractor() {
        let locationService = LocationAPI()
        let locationManager = CLLocationManager()
        locationInteractor = LocationInteractor(locationManager: locationManager, locationService: locationService, delegate: self)
    }
    
    func configureMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView.camera = camera
    }
    
    func setCurrentLocationMark(location: Location) {
        let marker = GMSMarker()
        marker.position = location.cLLocationCoordinate2D
        marker.map = mapView
        marker.icon = UIImage(named: "userMarker")
        mapView.camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 16)
    }
    
    func setNearByLocationsMarks(locations: [Location]) {
        for location in locations {
            let marker = GMSMarker()
            marker.position = location.cLLocationCoordinate2D
            marker.map = mapView
        }
    }
    
}

extension ViewController: LocationPresenterDelegate {
    func presentCurrent(location: Location) {
        self.setCurrentLocationMark(location: location)
        self.locationInteractor.getNearestPointsToCurrentDeviceLocation()
    }
    
    func presentNearBy(locations: [Location]) {
        self.setNearByLocationsMarks(locations: locations)
    }
}

