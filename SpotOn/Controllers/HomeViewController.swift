//
//  HomeViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/11/21.
//

import UIKit
import MapKit
import CoreLocation
import Floaty
import Parse

class HomeViewController: UIViewController {
    
    //MARK:- Variables
    //TODO: Connect all the outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var geoTestLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    
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
    var setIndexNum : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //floating button setUp
        let floatingButton = FloatingButton(controller: self)
        floatingButton.test = self  
        floatingButton.addButtons(with: pinImageView)
        
        
        //invite or accept
        floatingButton.addItem("Connect", icon: UIImage(named: "connect")){ item in
            let alertVc = AlertService().alert(me: self)
            alertVc.modalPresentationStyle = .overCurrentContext
            alertVc.providesPresentationContextTransitionStyle = true
            alertVc.definesPresentationContext = true
            alertVc.modalTransitionStyle = .crossDissolve
            self.present(alertVc, animated: true, completion: nil)
            
        }
        
        view.addSubview(floatingButton)
        setConstraints(floatingButton: floatingButton)
        
        
        setWeatherManager()
        checkLocationServices()
        overrideUserInterfaceStyle = .light //light mode by default
        
    }
    
    
    //constraint for FLoating Action Button
    func setConstraints(floatingButton : FloatingButton){
        //constraints
        //floaty.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        floatingButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        floatingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}

// MARK:- Setup Functions
extension HomeViewController{
    //MARK:- Map helper functions
    
    
    //checks if high level local service is on
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            //setup location manager
            print("checkLocationServices")
            setUpLocationManager()
        }else{
            //show alert letting user know to turn on their location
            print("No location enabled")
        }
    }
    
    //sets delegate
    //call request to share location if location is not set
    func setUpLocationManager(){
        print("setUpLocationManager")
        locationManger.delegate = self
        mapView.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManger.allowsBackgroundLocationUpdates = true
        locationManger.requestAlwaysAuthorization()
        //Chris added this part + plist changed
        locationManger.requestWhenInUseAuthorization()
        locationManger.requestLocation()
    }
    
    //adjust the camera view of the map
    //or zooms into the user location
    func zoomInUserLocation(){
        if let location = locationManger.location?.coordinate{
            print("when zooming : ", location)
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: zoomMagnitude, longitudinalMeters: zoomMagnitude)
            mapView.setRegion(region, animated: true)
            
        }
    }
    
    // Chris added weather set func
    func setWeatherManager() {
        self.weatherManager.delegate = self
    }
    
    func alert() {
        let alert = UIAlertController(title: "Did not allow SpotOn to know your location!", message: "It's recommended you allow SpotOn to know your location to fully utilize its features. Please go to settings and allow SpotOn to know your location.", preferredStyle: .alert)
        self.present(alert, animated: true)
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(getLocationsUpdates), userInfo: nil, repeats: true)
    }
}

// MARK:- CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate, Test{
    
    //runs when called from Test protocol
    func run(isHidden : Bool){
        if(isHidden){
            getDirection()
        }else{
            self.mapView.userTrackingMode = .followWithHeading
        }
    }
    
    
    func render(_ location : CLLocation){
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: zoomMagnitude, longitudinalMeters: zoomMagnitude)
        //let pin = MKPointAnnotation()
        weatherManager.fetchWeather(latitude: center.latitude, longitude: center.longitude) // Chris added this part
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update locations when user move
        print("test")
        guard let location = locations.last else {return}
        previousLocation = location
        render(location)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization(manager)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // Helper functions
    func startTrackingLocation() {
        print("startTrackingLocation")
        mapView.showsUserLocation = true
        zoomInUserLocation()
        locationManger.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func checkAuthorization(_ manager: CLLocationManager) {
        print("checkAuthorization")
        switch  manager.authorizationStatus {
        case .authorizedAlways , .authorizedWhenInUse:
            print("always and when in use")
            startTrackingLocation()
            break
        case .notDetermined , .denied , .restricted:
            print("denied")
            alert() // Chris added this part
            break
        default:
            print("wow nothing worked")
            break
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        print("getCenterLocation")
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDirection() {
        //make sure we got user location
        guard let location = locationManger.location?.coordinate else {
            //TODO: Inform the user we don't have their location
            
            return
        }
        
        let request = createDirectionRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapview(withNew: directions)
        
        directions.calculate { response, error in
            //TODO: Handle error if needed
            guard let response = response else { return }
            
            //for multiple routes
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.userTrackingMode = .followWithHeading
            }
        }
        pinImageView.isHidden = true
    }
    
    func getDirectionForGroup(accessKey: String, inSession: Bool) {
        if !inSession {
            //make sure we got user location
            guard let location = locationManger.location?.coordinate else {
                //TODO: Inform the user we don't have their location
                
                return
            }
            print("Creating Query")
            network.createLiveQuery { travel in
                self.setIndexNum = 0
                travel["access"] = accessKey
                travel["author"] = PFUser.current()!
                //travel["objectId"] = accessKey
                let myCoordinates = [location.latitude, location.longitude]
                let destinationCoordinates = self.getDestinationCoordinates()
                let aDestinationCoordinates = [destinationCoordinates.latitude, destinationCoordinates.longitude]
                travel["startCoordinates"] = myCoordinates
                travel["destinationCoordinates"] = aDestinationCoordinates
                travel["userCount"] = [[self.setIndexNum]]
                travel["position"] = [[location.latitude, location.longitude]]
               // var userCount = travel["userCount"] as! [[PFUser: Int]]
                travel.saveInBackground()
                //print(travel.objectId)
                
                print("Query Created :D")
            }
            
            let request = createDirectionRequest(from: location)
            let directions = MKDirections(request: request)
            resetMapview(withNew: directions)
            
            directions.calculate { response, error in
                //TODO: Handle error if needed
                guard let response = response else { return }
                //for multiple routes
                for route in response.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.userTrackingMode = .followWithHeading
                }
            }
            pinImageView.isHidden = true
            print("Sent directions")
        }
    }
    
    func getDirectionFromGroup() {
        guard let location = locationManger.location?.coordinate else {
            //TODO: Inform the user we don't have their location
            return
        }
        network.userJoinedSession(accessKey: myAccessKey ?? "") { travel in
            print("Query joined :3")
            var userCount = travel["userCount"] as! [[Int]]
            var positions = travel["position"] as! [[CLLocationDegrees]]
            let startCoordinates = travel["startCoordinates"] as! [CLLocationDegrees]
            let destinationCoordinates = travel["destinationCoordinates"] as! [CLLocationDegrees]
            let startCoordinatesCLL = CLLocationCoordinate2D(latitude: startCoordinates[0] , longitude: startCoordinates[1] )
            let destinationCoordinatesCLL = CLLocationCoordinate2D(latitude: destinationCoordinates[0] , longitude: destinationCoordinates[1] )
            
            let request = self.createDirectionRequestForOthers(from: startCoordinatesCLL, to: destinationCoordinatesCLL)
            self.setIndexNum = userCount.last![0] + 1
            userCount.append([self.setIndexNum])
            travel["userCount"] = userCount
            positions.append([location.latitude, location.longitude])
            travel["position"] = positions
            let directions = MKDirections(request: request)
            
            self.resetMapview(withNew: directions)
            
            directions.calculate { response, error in
                //TODO: Handle error if needed
                guard let response = response else { return }
                //for multiple routes
                for route in response.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.userTrackingMode = .followWithHeading
                }
            }
            self.pinImageView.isHidden = true
            print("Sent directions")
            travel.saveInBackground()
            print("Saved stuff :3")
            
        } failure: { error in
            print("Error \(error.localizedDescription)")
        }

        
    }
    
    
    @objc func getLocationsUpdates() {
        guard let location = locationManger.location?.coordinate else {
            //TODO: Inform the user we don't have their location
            return
        }
        removeAnnotations()
        network.liveLocationUpdates(accessKey: myAccessKey ?? "") { travel in
            var usersPositions = travel["position"] as! [[CLLocationDegrees]]
            let userCount = travel["userCount"] as! [[Int]]
            let myCount = userCount.last?.last!
            print("My Count \(myCount!)")
            let myAnnotations = Array(repeating: MKPointAnnotation(), count: myCount!)
            for count in userCount {
                for position in usersPositions {
                    if count[0] != self.setIndexNum {
                        let lat = position[0]
                        let lon = position[1]
                        
                        let a = count[0]
                        print(a)
                        //let lat = usersPositions[a][0]
                        //let lon = usersPositions[a][1]
                        let c = CLLocationCoordinate2D(latitude: lat , longitude: lon )
                        myAnnotations[a].coordinate = c
                        self.mapView.addAnnotation(myAnnotations[a])
                    }
                }
            }
            // update my locaiton on parse
            let myPos = [location.latitude, location.longitude]
            print("Index :\(self.setIndexNum!)")
            usersPositions[self.setIndexNum] = myPos
            travel["position"] = usersPositions
            travel.saveInBackground()
            
        } failure: { error in
            print("Error: \(error)")
        }

    }
    
    //remove overlays from map
    func resetMapview(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArrya.append(directions)
        let _ = directionsArrya.map({$0.cancel()})
        self.mapView.userTrackingMode = .none
    }
    
    //requets helper function
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = getDestinationCoordinates()
        let startingPosition = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        //create request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingPosition)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    //requets helper function for others
    func createDirectionRequestForOthers(from coordinate: CLLocationCoordinate2D, to toCoordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = toCoordinate
        let startingPosition = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        //create request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingPosition)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    func getDestinationCoordinates() -> CLLocationCoordinate2D {
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        return destinationCoordinate
    }
    
    func removeAnnotations() {
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
    }
}

// MARK:- WeatherManagerDelegate
extension HomeViewController: WeatherManagerDelegate {
    //Chris Added this part
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        //Move to main thread
        DispatchQueue.main.async {
            self.tempLabel.text = weather.temperatureString + "°"
            self.cityLabel.text = weather.cityName
            print("weather conditionname : ", weather.conditionName)
            self.tempImageView.image = UIImage(named: weather.conditionName)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

// MARK:- MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("regionDidChanged")
        //if pin is not active, do not calc
        if pinImageView.isHidden != true {
            let center = getCenterLocation(for: mapView)
            let geoCoder = CLGeocoder()
            
            guard let previousLocation = self.previousLocation else { return }
            
            guard center.distance(from: previousLocation) > 50 else { return }
            self.previousLocation = center
            
            geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                
                if let _ = error {
                    //TODO: Show alert informing the user
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    //TODO: Show alert informing the user
                    return
                }
                
                let streetNumber = placemark.subThoroughfare ?? ""
                let streetName = placemark.thoroughfare ?? ""
                
                //move to main thread
                DispatchQueue.main.async {
                    if self.pinImageView.isHidden != true {
                        //self.geoTestLabel.text = "\(streetNumber) \(streetName)"
                        self.searchTextField.text = "\(streetNumber) \(streetName)"
                    }
                }
            }
        }
    }
    
    //rederer func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

extension HomeViewController : GeneratedToHomeDelegate{
    func gotoHomeAndAction(access: String, createSession: Bool) {
        myAccessKey = access
        if createSession {
            getDirectionForGroup(accessKey: myAccessKey!, inSession: inOnlineSession)
        } else {
            getDirectionFromGroup()
        }
        scheduledTimerWithTimeInterval()
    }
}
