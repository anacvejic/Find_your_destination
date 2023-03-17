//
//  SearchViewController.swift
//  Find_destination
//
//  Created by anacvejic on 2/23/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CustomPin: MKPointAnnotation {
    var color: UIColor?
}


class SearchViewController: UIViewController {
    
    let mapView = MKMapView()
    var searchLocation: Location?
    var endLoca: Location!
    var search: String = ""
    var endSearch: String = ""
    let regionMetters: Double = 10000
    
    let locationManager = CLLocationManager()
    var selectedPin: MKPlacemark!
    var button: UIButton!
    
    var searchVC = UISearchController(searchResultsController: SearchDestinationViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(mapView)
        
        locationManager.startUpdatingLocation()
        self.navigationController?.isNavigationBarHidden = false
        
        let locationSearchTable = SearchDestinationViewController()
            searchVC = UISearchController(searchResultsController: locationSearchTable)
            searchVC.searchResultsUpdater = locationSearchTable
         
            let serachBar = searchVC.searchBar
            serachBar.sizeToFit()
            serachBar.placeholder = "Search destination..."
            navigationItem.titleView = searchVC.searchBar
            searchVC.hidesNavigationBarDuringPresentation = false
            searchVC.obscuresBackgroundDuringPresentation = true
            searchVC.searchBar.backgroundColor = .secondarySystemBackground
            definesPresentationContext = true
        
            locationSearchTable.mapView = mapView
            locationSearchTable.handleMapSearchDelegate = self
        
    
        
        if endSearch != ""{
            self.search = ""
        }else {
            self.endSearch = ""
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    //Mark: Action
    
    private func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin{
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
}

//Mark: Extenstion

extension SearchViewController: CLLocationManagerDelegate, UISearchControllerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse{
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first{
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
            if search == "search"{
                self.searchLocation = Location(title:"Current location", coordinate: location.coordinate)
                mapView.addAnnotation(self.searchLocation!)
                mapView.setRegion(region, animated: true)
            }else if endSearch == "end location"{
                self.endLoca = Location(title:"Your destination", coordinate: location.coordinate)
            }
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("ERROR: \(error)")
    }
}

extension SearchViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        if search == "search"{
            
            self.searchLocation = Location(title:"Current location", coordinate: placemark.coordinate)
            mapView.addAnnotation(self.searchLocation!)
        }else if endSearch == "end location"{
            self.endLoca = Location(title:"Your destination", coordinate: placemark.coordinate)
            mapView.addAnnotation(self.endLoca)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

//Mark: Protocol

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

