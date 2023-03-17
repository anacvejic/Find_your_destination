//
//  ViewController.swift
//  Find_destination
//
//  Created by anacvejic on 2/15/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var btnPinLocation: UIButton!
    @IBOutlet weak var lblCurentDestination: UILabel!
    @IBOutlet weak var lblEndDestination: UILabel!
    @IBOutlet weak var btnSearchDestination: UIButton!
    @IBOutlet weak var btnNavigation: UIButton!
    @IBOutlet weak var btnClearControl: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewMainControl: UIView!
    
    private var currentPlace: CLPlacemark?
    private var currentRegion: MKCoordinateRegion?
    private let completer = MKLocalSearchCompleter()
    
    var coordinate: Location!
    var endLocation: Location?
    var search: String = ""
    var endSearch: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutControl()
        setControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         self.navigationController?.isNavigationBarHidden = true
         view.layer.contents = #imageLiteral(resourceName: "map1").cgImage
        
        if let coord = coordinate?.coordinate{
            
            scrollView.isHidden = false
            btnClearControl.isHidden = false
            btnNavigation.isHidden = true
            convertGeoLocation(locations: coord, label: lblCurentDestination)
       }
        if let endLocation = endLocation?.coordinate{
            
            scrollView.isHidden = false
            btnClearControl.isHidden = false
            btnNavigation.isHidden = false
            convertGeoLocation(locations: endLocation, label: lblEndDestination)
        }
    }
    
    
    //Mark: Action
    
    @IBAction func btnPinLocationTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let automaticLocation = UIAlertAction(title: "Pin your location custom", style: .default) { (_) in
            self.performSegue(withIdentifier: "automatic", sender: self)
        }
        let manualLocation = UIAlertAction(title: "Pin your location manualy", style: .default) { (_) in
            self.performSegue(withIdentifier: "manual", sender: self)
        }
        
        let searchMap = UIAlertAction(title: "Pin your location by addresse", style: .default) { (_) in
            self.search = "search"
            self.endSearch = ""
            self.performSegue(withIdentifier: "search", sender: self)
        }
        
        alert.addAction(automaticLocation)
        alert.addAction(manualLocation)
        alert.addAction(searchMap)
        self.present(alert, animated: true)
        
    }
    
    
    @IBAction func btnSearchEndSestinationTapped(_ sender: Any) {
        
        self.endSearch = "end location"
        self.performSegue(withIdentifier: "search", sender: self)
    }
    
    
    @IBAction func btnNavigationTapped(_ sender: Any) {
        
        let alertControler = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let startNavigation = UIAlertAction(title: "Start navigation", style: .default) { (_) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "startNavigation") as? StartNavigationViewController
            newViewController?.modalTransitionStyle = .crossDissolve
            newViewController?.currentDestination = self.coordinate
            newViewController?.destination = self.endLocation
            self.navigationController?.pushViewController(newViewController!, animated: true)
        }
        
        let showRoot = UIAlertAction(title: "See the steps root", style: .default) { (_) in
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "stepRoot") as? StepRootViewController
            newViewController?.modalTransitionStyle = .crossDissolve
            newViewController?.startLocation = self.coordinate
            newViewController?.endLocation = self.endLocation
            self.navigationController?.pushViewController(newViewController!, animated: true)
            
        }
        
        alertControler.addAction(startNavigation)
        alertControler.addAction(showRoot)
        self.present(alertControler, animated: true)
    }
    
    @IBAction func performSegue(withIdentifier identifier: String) {}
    
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {
        
        if let autoLoca = unwindSegue.source as? AutomaticLocationViewController{
            
            guard let autolocation = autoLoca.curentLocation else{
                return
            }
            self.coordinate = Location(title: "", coordinate: autolocation.coordinate)
            
        }
        
        if let manual = unwindSegue.source as? ManualLocationViewController{
            guard let manual = manual.currentLocation else{
                return
            }
            self.coordinate = Location(title: "", coordinate: manual.coordinate)
        }
        
        if let endLoca = unwindSegue.source as? SearchViewController{
            
            if let endlocation = endLoca.endLoca{
                self.endLocation = Location(title: "", coordinate: endlocation.coordinate)
            }else if let searchLocation = endLoca.searchLocation{
                self.coordinate = Location(title: "", coordinate: searchLocation.coordinate)
            }
            
        }
        
    }
    
    
    @IBAction func btnClearTapped(_ sender: Any) {
        
        self.btnClearControl.isHidden = true
        self.scrollView.isHidden = true
    }
    
    
    
    //Mark: Functions
    
    func setControl(){
        
        scrollView.isHidden = true
        btnClearControl.isHidden = true
    }
    
    func setLayoutControl(){
        
        
        self.btnPinLocation.layer.cornerRadius = 13
        self.btnPinLocation.layer.borderWidth = 1
        self.btnPinLocation.layer.borderColor = UIColor.black.cgColor
        
        self.btnSearchDestination.layer.cornerRadius = 13
        self.btnSearchDestination.layer.borderWidth = 2
        self.btnSearchDestination.layer.borderColor = UIColor.systemGray.cgColor
        
        self.btnNavigation.layer.cornerRadius = 13
        self.btnNavigation.layer.borderWidth = 2
        self.btnNavigation.layer.borderColor = UIColor.systemGray.cgColor
        
        self.btnClearControl.layer.cornerRadius = 13
        self.btnClearControl.layer.borderWidth = 1
        self.btnClearControl.layer.borderColor = UIColor.black.cgColor
        
        self.lblCurentDestination.layer.cornerRadius = 10
        self.lblCurentDestination.layer.borderWidth = 2
        self.lblCurentDestination.layer.borderColor = UIColor.systemGray.cgColor
        self.lblCurentDestination.layer.masksToBounds = true
        
        self.lblEndDestination.layer.cornerRadius = 10
        self.lblEndDestination.layer.borderWidth = 3
        self.lblEndDestination.layer.borderColor = UIColor.systemGray.cgColor
        self.lblEndDestination.layer.masksToBounds = true
        
    }
    
    func convertGeoLocation(locations: CLLocationCoordinate2D, label: UILabel){
        
        let addressse = CLGeocoder.init()
        addressse.reverseGeocodeLocation(CLLocation.init(latitude: locations.latitude, longitude: locations.longitude)) { (places, error) in
            
            if error == nil && places!.count > 0{
                let place = places?.last
                let adresse = "\(place!.name!), \(place!.subLocality!) \(place!.locality!)"
                label.text = adresse
                self.currentPlace = places?.first
            }else{
                self.alert(title: "Warning", message: "The coordinates entered were not found!")
                self.scrollView.isHidden = true
                self.btnClearControl.isHidden = true
                return
            }
        }
    }
    
    private func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "search"{
            let param = segue.destination as! SearchViewController
            param.search = search
            param.endSearch = endSearch
        }
    }
    
}

