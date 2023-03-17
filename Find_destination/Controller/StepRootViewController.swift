//
//  StepRootViewController.swift
//  Find_destination
//
//  Created by anacvejic on 2/27/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StepRootViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    
    var startLocation: Location!
    var endLocation: Location!
    var currentRoute: MKRoute?
    var currentStepIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        self.navigationController?.isNavigationBarHidden = false
        
        setPinAnnotation()
        getDirection()
    }
    
    //Mark: Function
    
    func getDirection(){
        
        let request = MKDirections.Request()
        
        //Start location
        let sourcePLacemark = MKPlacemark(coordinate: startLocation.coordinate)
        request.source = MKMapItem(placemark: sourcePLacemark)
        
        let region = MKCoordinateRegion(center: startLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        //End location
        let destPlacemark = MKPlacemark(coordinate: endLocation.coordinate)
        request.destination = MKMapItem(placemark: destPlacemark)
        //Transport Type
        request.transportType = [.automobile, .walking]
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            
            guard let response = response else{
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }
            
            let route = response.routes[0]
            self.currentRoute = route
            self.currentSteps()
            self.mapView.addOverlay(route.polyline)
        }
    }
    
    func currentSteps(){
        
        guard let currentRoute = currentRoute else {
            return
        }
        if currentStepIndex >= currentRoute.steps.count{
            return
        }
        let step = currentRoute.steps[currentStepIndex]
        
        btnPrevious.isEnabled = currentStepIndex > 0
        btnNext.isEnabled = currentStepIndex < (currentRoute.steps.count-1)
        
        self.lblInstructions.text = step.instructions
        Speech.shared.voiceMessage(message: self.lblInstructions.text!)
        lblDistance.text  = "\(distanceConverter(distance: step.distance))"
        
        mapView.setVisibleMapRect(step.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 100, right: 40), animated: true)
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
    
    func setPinAnnotation(){
        
        startLocation = Location(title: "Start point", coordinate: startLocation.coordinate)
        endLocation = Location(title: "End point", coordinate: endLocation.coordinate)
        mapView.addAnnotation(startLocation)
        mapView.addAnnotation(endLocation)
        
    }
    
    //Mark: Actions
    
    
    @IBAction func btnNextStepTapped(_ sender: Any) {
        
        guard let currenRoute  = currentRoute else {
            return
        }
        
        if currentStepIndex >= (currenRoute.steps.count-1){
            return
        }
        
        currentStepIndex += 1
        currentSteps()
    }
    
    
    @IBAction func btnPreviousStepTapped(_ sender: Any) {
        
        if currentRoute == nil{
            return
        }
        if currentStepIndex <= 0{
            return
        }
        
        currentStepIndex -= 1
        currentSteps()
    }
}


extension StepRootViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay)
        //Set color of line route
        render.strokeColor = .red
        render.lineWidth = 3
        
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
              annotationView?.canShowCallout = true
          }else{
              annotationView?.annotation = annotation
          }
          
          return annotationView
      }
}

