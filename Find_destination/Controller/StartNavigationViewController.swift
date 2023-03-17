//
//  StartNavigationViewController.swift
//  Find_destination
//
//  Created by anacvejic on 3/9/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit

class StartNavigationViewController: UIViewController {
    
    
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnGO: UIButton!
    
    var currentDestination: Location?
    var destination: Location?
    
    var navigationStarted = false
    var showMapRoute = false
    var route: MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        btnGO.layer.cornerRadius = 30
        
        showRootOnMap(start: currentDestination!.coordinate, end: destination!.coordinate)
        btnGO.addTarget(self, action: #selector(startSropButtunTapped), for: .touchUpInside)
        
    }

    //Mark: Action
    
    @objc fileprivate func startSropButtunTapped(){
        
        if !navigationStarted{
            showMapRoute = true
            let center = currentDestination?.coordinate
                centerViewToUserLocation(center: center!)
        }else{
            if let route = route{
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
            }
        }
        
        navigationStarted.toggle()
        btnGO.setTitle(navigationStarted ? "Stop" : "GO", for: .normal)
        
    }
    
    
    //Mark Function
    
    func setUpMap(){
        
        currentDestination!.title = "Current destination"
        destination!.title = "End destination"
        mapView.addAnnotations([currentDestination!, destination!])
        
    }
    
    func centerViewToUserLocation(center: CLLocationCoordinate2D){
        //Set region...
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func showRootOnMap(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D){
        
        setUpMap()
        
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        centerViewToUserLocation(center: start)
        request.requestsAlternateRoutes = true
        request.transportType = [.automobile, .walking]
        
        let direction = MKDirections(request: request)
        
        direction.calculate { [weak self](response, error) in
            
            guard let response = response else{
                let alert = UIAlertController(title: "Warning", message: "We don't have your current location!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                self!.present(alert, animated: true)
                return
            }
            
           
            if let route = response.routes.first{
                //Show on map
                self?.mapView.addOverlay(route.polyline)
                //Set map the map area to show the route
                self?.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8), animated: true)

                self?.route = route
                self!.lblInformation.text = ""
                self?.convertGeoLocation(locations: end, label: self!.lblInformation)

            }
        }
    }
    
    func distanceConverter(distance: CLLocationDistance)->String{
        
        let formater = LengthFormatter()
        formater.numberFormatter.maximumFractionDigits = 2
        if NSLocale.current.usesMetricSystem{
            return formater.string(fromValue: distance/1000, unit: .kilometer)
        }else{
            return formater.string(fromValue: distance/1609.34, unit: .mile)
        }
    }
    
    func convertGeoLocation(locations: CLLocationCoordinate2D, label: UILabel){
        
        let addressse = CLGeocoder.init()
        addressse.reverseGeocodeLocation(CLLocation.init(latitude: locations.latitude, longitude: locations.longitude)) { (places, error) in
            
            if error == nil && places!.count > 0{
                let place = places?.last
                let adresse = "\(place!.name!), \(place!.subLocality!) \(place!.locality!)"
                label.text! += "Direction to \(adresse)"
                label.text! += "\n" + "\(self.distanceConverter(distance: self.route!.distance))"
            }else{
                return
            }
        }
    }
    
}

//Mark: Extension

extension StartNavigationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay)
        //Set color of line route
        render.strokeColor = .red
        render.lineWidth = 5
        print("JUPI")
        return render
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is Location  else{
            return nil
        }
        
        let identifire = "id"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifire)
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifire)
            annotationView!.canShowCallout = true
        }else{
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
}
