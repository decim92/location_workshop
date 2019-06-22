//
//  LocationAPI.swift
//  Location Workshop
//
//  Created by Douglas on 6/15/19.
//  Copyright © 2019 Douglas. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class LocationAPI: LocationServiceProtocol {
    
    private func getLocationsUrl () -> String {
        return "\(ApiConstants.baseUrl)\(ApiConstants.getLocationsEndpoint)"
    }
    
    func getLocationsFrom(location: Location, radiusInMeters: Int, successCompletion: @escaping (Array<Location>) -> (), errorCompletion: @escaping (Error) -> ()) {
        let url = getLocationsUrl()
        let params = ["lat": location.latitude!,
                      "lon": location.longitude!,
                      "radius": radiusInMeters,
                      "limit": ApiConstants.locationsRecordRequestLimit] as [String : Any]
        Alamofire.SessionManager.default.request(url, method: .get, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode {
                    if statusCode >= 400{
                        let error = NSError(domain:"test.domain",
                                            code:statusCode,
                                            userInfo:[NSLocalizedDescriptionKey:"Error"])
                        errorCompletion(error)
                    }else {
                        var locations = [Location]()
                        if let value = response.result.value {
                            let json = JSON(value)
                            if let markers = json["data"]["markers"].array {
                                locations = self.locationsFrom(markers: markers)
                            }
                        }
                        successCompletion(locations)
                    }
                }
            case .failure(let error):
                errorCompletion(error)
            }
        }
    }
    
    private func locationsFrom(markers: [JSON]) -> [Location] {
        var locations = [Location]()
        for locationJson in markers {
            let location = Location(json: locationJson)
            locations.append(location)
        }
        return locations
    }
}
