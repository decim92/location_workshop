//
//  File.swift
//  Location Workshop
//
//  Created by Douglas on 6/15/19.
//  Copyright © 2019 Douglas. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import GoogleMaps

class Location {
    var latitude:Double!
    var longitude:Double!
    
    init() {
        
    }
    
    convenience init(latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    convenience init (json: JSON) {
        self.init()
        self.latitude = json["lat"].double
        self.longitude = json["long"].double
    }
    
    func cLLocation () -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var cLLocationCoordinate2D:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension CLLocation {
    func toLocation () -> Location {
        return Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
