//
//  ManualLocationViewController.swift
//  Find_destination
//
//  Created by anacvejic on 2/26/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ManualLocationViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblAddresse: UILabel!
    
    let regionMetters: Double = 10000
    var currentLocation: Location?
    var previousLocation: CLLocation?
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            handleAuthorizationStatus(locationManager: locationManager, status: CLLocationManager.authorizationStatus())
        }else{
            print("Location service is not enabled!")
            alert(title: "Warning", message: "You should tourn on location service in your phone setting")
        }
        
        return locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startUpdatingLocation()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    //Mark: Function
    
    private func handleAuthorizationStatus(locationManager: CLLocationManager, status: CLAuthorizationStatus){
        
        switch status {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            if let center = locationManager.location?.coordinate{
                mapView.showsUserLocation = true
                LocationManager.shared.centerViewToUserLocation(center: center, mapView: self.mapView, locationDistance: regionMetters)
                self.previousLocation = getCenterLocation(for: self.mapView)
            }
            break
        @unknown default:
            break
        }
    }
    
    private func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    func getCenterLocation(for mapView: MKMapView)->CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}

//Mark: Extension

extension ManualLocationViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        handleAuthorizationStatus(locationManager: manager, status: status)
    }
}



extension ManualLocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else {
            return
        }
        
        guard center.distance(from: previousLocation) > 50 else{
            return
        }
        
        self.previousLocation = center
        currentLocation = Location(title: "", coordinate: center.coordinate)
        
        geocoder.reverseGeocodeLocation(center) { [weak self] (placemark, error) in
            
            guard let self = self else {
                return
            }
            if let _ = error{
                return
            }
            guard let placemark = placemark?.first else{
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.lblAddresse.text = "\(streetName) \(streetNumber)"
            }
        }
    }
}
