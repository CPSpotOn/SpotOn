//
//  LocalData.swift
//  SpotOn
//
//  Created by Christopher Mena on 6/11/21.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Floaty
import Parse
import Alamofire
import AlamofireImage

class LocalData {
    //TODO: Add any required variables
    let locationManger = CLLocationManager()
    let zoomMagnitude : Double = 1000; // Zoomed in a little more, prev was 10000
    var weatherManager = WeatherManager() //Chris added this
    var previousLocation : CLLocation?
    var directionsArrya: [MKDirections] = []
    var network = NetworkCalls()
    var inOnlineSession = false
    var myAccessKey : String?
    var timer = Timer()
    var setIndexNum: Int =  0
    var userAnnotations = [GuestAnnotation(title: nil, locationName: nil, discipline: nil, coordinate: nil, subtitle: nil)]
    var userTrackCount : Int = 0
    var myUser = PFUser.current()!
    var accessKey = "";
    var settings = AppSetting()
    var transportMethod = MKDirectionsTransportType()
    var centerToggel = false
    var imageUser = [UIImage]()
    let searchVc = UISearchController(searchResultsController: SearchResultViewController())
}
