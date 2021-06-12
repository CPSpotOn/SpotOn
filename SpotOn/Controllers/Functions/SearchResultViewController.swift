//
//  SearchResultViewController.swift
//  SpotOn
//
//  Created by Christopher Mena on 6/9/21.
//

import UIKit
import CoreLocation
protocol SearchResultDelegate {
    func didTapPlace(lat: CLLocationDegrees, lon: CLLocationDegrees, address: String)
}

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Variables
    var places : [SearchModel] = []
    var delegate : SearchResultDelegate?
    
    let tableView: UITableView = {
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
        tableView.frame = view.bounds
    }
    
    func update(with: [SearchModel]) {
        self.places = with
        print(with.count)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = places[indexPath.row].freeformAddress
        
       // cell.textLabel?.text = places[indexPath.row].freeformAddress![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let addressObject = places[indexPath.row]
        delegate?.didTapPlace(lat: addressObject.latitude, lon: addressObject.longitude, address: addressObject.freeformAddress)
        self.dismiss(animated: true, completion: nil)
    }
}
 
