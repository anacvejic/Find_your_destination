//
//  SearchDestinationViewController.swift
//  Find_destination
//
//  Created by anacvejic on 2/23/23.
//  Copyright © 2023 anacvejic. All rights reserved.
//

import UIKit
import MapKit

class SearchDestinationViewController: UIViewController {
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    
    private let tableView: UITableView = {
        
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        view.backgroundColor = .systemGray
        tableView.frame = view.bounds
    }
    
    func parseAddresse(selectedItem: MKPlacemark) -> String{
        
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? ", " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(format:"%@%@%@%@%@%@%@", selectedItem.subThoroughfare ?? "", firstSpace, selectedItem.thoroughfare ?? "",
            comma, selectedItem.locality ?? "", secondSpace, selectedItem.administrativeArea ?? "")
        
        return addressLine
    }
}

//Mark: Extension

extension SearchDestinationViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let mapView = mapView, let searcBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searcBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            
            guard let response = response else{return}
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension SearchDestinationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let selectedItems = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItems.name
        cell.detailTextLabel?.text = parseAddresse(selectedItem: selectedItems)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}
