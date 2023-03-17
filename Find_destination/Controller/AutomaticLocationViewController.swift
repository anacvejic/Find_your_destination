//
//  AutomaticLocationViewController.swift
//  Find_destination
//
//  Created by anacvejic on 2/15/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AutomaticLocationViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblAddresse: UILabel!
    
    let regionMeters: Double = 10000
    var curentLocation: Location!
    
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
    
    //Mark: Functions
    
        
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
                LocationManager.shared.centerViewToUserLocation(center: center, mapView: self.mapView, locationDistance: regionMeters)
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
    
    //Mark: Action
    
    @IBAction func btnBack(_ sender: Any) {
    }
}

//Mark: Extension

extension AutomaticLocationViewController: CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        
       let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
        mapView.setRegion(region, animated: true)
        
        curentLocation = Location(title: "Current location!", coordinate: center)
        mapView.addAnnotation(self.curentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       
        handleAuthorizationStatus(locationManager: manager, status: status)
    }
}

extension AutomaticLocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is Location  else{
            return nil
        }
        
        let identifire = "id"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifire)
        
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifire)
            annotationView?.canShowCallout = true
        }else{
            annotationView?.annotation = annotation
        }
        
        let cor = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        LocationManager.shared.resolveLocationName(with: cor) { locationName in
            
            self.lblAddresse.text = locationName
        }
        return annotationView
    }
    
    
}
