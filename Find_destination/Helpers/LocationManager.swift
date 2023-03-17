//
//  LocationManager.swift
//  Find_destination
//
//  Created by anacvejic on 2/15/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject{
    
    static let shared = LocationManager()
    
    
    public func resolveLocationName(with location: CLLocation, completion: @escaping((String?)->Void)){
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
            
            guard let place = placemarks?.first, error == nil else{
                completion(nil)
                return
            }
            
            print("PLACE: \(place)")
            
            var name = ""
            
            if let name1 = place.name{
                name += name1
            }
            if let locality = place.locality{
                name += ", \(locality)"
            }
            if let area = place.country{
                name += " \(area)"
            }
            
            completion(name)
        }
    }
    
    public func centerViewToUserLocation(center: CLLocationCoordinate2D, mapView: MKMapView, locationDistance: Double){
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
    }
}
