//
//  Location.swift
//  Find_destination
//
//  Created by anacvejic on 2/19/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit

class Location: NSObject, MKAnnotation {
    
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.coordinate = coordinate
    }
}
