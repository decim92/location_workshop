//
//  LocationManager.swift
//  Location Workshop
//
//  Created by Douglas on 6/15/19.
//  Copyright © 2019 Douglas. All rights reserved.
//

import UIKit
import CoreLocation

enum PermissionStatus {
    case permissionStatusGranted
    case permissionStatusDenied
}

protocol LocationManagerProtocol {
    func requestPermission()
    func getPermissionStatus() -> PermissionStatus
    func requestCurrentLocation(delegate: CLLocationManagerDelegate)
    func stopListeningLocation()
}

protocol LocationServiceProtocol {
    func getLocationsFrom(location: Location, radiusInMeters: Int, successCompletion: @escaping (Array<Location>) -> (), errorCompletion: @escaping (Error) -> ())
}

protocol LocationPresenterDelegate {
    func presentCurrent(location: Location)
    func presentNearBy(locations: [Location])
}

class LocationInteractor: NSObject {
    private var location:Location?
    private var locationManager: LocationManagerProtocol!
    private var locationService: LocationServiceProtocol!
    var delegate: LocationPresenterDelegate!
    
    init(locationManager: LocationManagerProtocol, locationService: LocationServiceProtocol, delegate: LocationPresenterDelegate) {
        self.locationManager = locationManager
        self.locationService = locationService
        self.delegate = delegate
    }
    
    func requestDeviceLocation() {
        switch locationManager.getPermissionStatus() {
            case .permissionStatusDenied:
                self.locationManager.requestPermission()
            default:
                print("Handle other cases")
        }
        self.locationManager.requestCurrentLocation(delegate: self)
    }
    
    func getNearestPointsToCurrentDeviceLocation() {
        if let location = location {
            locationService.getLocationsFrom(location: location, radiusInMeters: ApiConstants.defaultLocationRadiusInMeters, successCompletion: { (locations) in
                self.delegate.presentNearBy(locations: locations)
            }) { (error) in
                //TODO: Handle error presentation
            }
        }
    }
}

extension LocationInteractor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            self.location = currentLocation.toLocation()
            self.delegate.presentCurrent(location: self.location!)
            self.locationManager.stopListeningLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension CLLocationManager: LocationManagerProtocol {
    func requestPermission() {
        self.requestWhenInUseAuthorization()
    }
    
    func getPermissionStatus() -> PermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined, .denied, .restricted:
            return .permissionStatusDenied
        case .authorizedAlways, .authorizedWhenInUse:
            return .permissionStatusGranted
        @unknown default:
            fatalError()
        }
    }
    
    func requestCurrentLocation(delegate: CLLocationManagerDelegate) {
        self.delegate = delegate
        self.startUpdatingLocation()
    }
    
    func stopListeningLocation() {
        self.stopUpdatingLocation()
    }
    
}
