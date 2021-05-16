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
    var setIndexNum = 0
    var userAnnotations = [GuestAnnotation(location: nil)]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userAnnotations[0].shown = false
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
        
        showClosestUsers()
        
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

//show closest users in the map
//calls the LiveTravel object
//and sets the pin to user current location
extension HomeViewController{
    func showClosestUsers(){
        //acess code : 060924
        //lat : 37.785834 , long : -122.406417
        let accessCode = "060924"
        let query = PFQuery(className: "LiveTravel")
        query.whereKey("access", contains: accessCode)
        query.includeKey("author")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error != nil{
                print("error : \(error?.localizedDescription)")
            }else{
                print("count : ", objects?.count)
                
                //the total users that is associated with the access code
                //if there are two users, they are shown in the map
                for user in objects! {
                    let author = user["author"] as! PFUser
                    DispatchQueue.main.async {
                        let pin = MKPointAnnotation()
                        pin.coordinate = CLLocationCoordinate2D(latitude: 37.79059491411279, longitude: -122.40690136825816)
                        pin.title = author["name"] as! String
                        self.mapView.addAnnotation(pin)
                    }
                }
            }
        }
    }
    
    //view of annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "user")
        if annotationView == nil{
            //Create custom view
        }else{
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    //when annotation is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotationTitle = view.annotation?.title
        {
            print("User tapped on annotation with title: \(annotationTitle!)")
            //calculate distance and add a route
            //make sure we got user location
            let sourcePlacemark = MKPlacemark(coordinate: (locationManger.location?.coordinate)!)
            let destPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.79059491411279, longitude: -122.40690136825816))
            let sourceItem = MKMapItem(placemark: sourcePlacemark)
            let destItem = MKMapItem(placemark: destPlacemark)
            
            let destinationRequest = MKDirections.Request()
            destinationRequest.source = sourceItem
            destinationRequest.destination = destItem
            destinationRequest.transportType = .automobile
            destinationRequest.requestsAlternateRoutes = false
            
            let direction = MKDirections(request: destinationRequest)
            direction.calculate { response, error in
                guard let response = response else{
                    if let error = error{
                        print("error :\(error)")
                    }
                    return
                }
                
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
        
    }
    
    //when annotation is deselected
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("DeSelect")
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
}
//end of show users and routes on the map



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
    
    //a scheduler that calls the function getLocationsUpdates every 1.0s
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(getLocationsUpdates), userInfo: nil, repeats: true)
    }
    
    func scheduledTimerWithTimeIntervalWaitinng() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { timer in
            print("Waiting.......")
        })
    }
    
    func setUpArrayAnnotations(userCount: Int) {
        print("Inside setupArray")
        for a in (0...userCount) {
            var a = GuestAnnotation(location: nil)
            a.shown = false
            userAnnotations.append(a)
        }
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
    
    
    //updates the current user location
    func render(_ location : CLLocation){
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: zoomMagnitude, longitudinalMeters: zoomMagnitude)
        //let pin = MKPointAnnotation()
        weatherManager.fetchWeather(latitude: center.latitude, longitude: center.longitude) // Chris added this part
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    //a CLLocationMangaer that manages the location object
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update locations when user move
        print("test")
        guard let location = locations.last else {return}
        previousLocation = location
        render(location)
    }
    
    //checks if user has changed authorization rules for accessing location
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization(manager)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // Helper functions
    //once called starts to track user location
    func startTrackingLocation() {
        print("startTrackingLocation")
        mapView.showsUserLocation = true
        zoomInUserLocation()
        locationManger.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    //frames the user to the center of the screen
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        print("getCenterLocation")
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //get the distance between the user and the other location
    //and draw a route between the distance
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
    
    
    //liveQuery
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
                travel["userCount"] = 0
                travel["position"] = [[location.latitude, location.longitude]]
                // var userCount = travel["userCount"] as! [[PFUser: Int]]
                travel.saveInBackground { success, error in
                    if error != nil {
                        print("Error: \(error?.localizedDescription)")
                    } else if success != nil {
                        print("Saved")
                    }
                }
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
        network.returnQuery(accessKey: myAccessKey ?? "") { travel in
            print("Query joined :3")
            var userCount = travel["userCount"] as! Int
            var positions = travel["position"] as! [[CLLocationDegrees]]
            let startCoordinates = travel["startCoordinates"] as! [CLLocationDegrees]
            let destinationCoordinates = travel["destinationCoordinates"] as! [CLLocationDegrees]
            let startCoordinatesCLL = CLLocationCoordinate2D(latitude: startCoordinates[0] , longitude: startCoordinates[1] )
            let destinationCoordinatesCLL = CLLocationCoordinate2D(latitude: destinationCoordinates[0] , longitude: destinationCoordinates[1] )
            
            let request = self.createDirectionRequestForOthers(from: startCoordinatesCLL, to: destinationCoordinatesCLL)
            
            self.setIndexNum = userCount + 1

            userCount = self.setIndexNum
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
        //Add new  user annotation
        var annonation = GuestAnnotation(location: nil)
        annonation.shown = false
        userAnnotations.append(annonation)
        scheduledTimerWithTimeIntervalWaitinng()
    }
    
    
    @objc func getLocationsUpdates() {
        print("Getting updates :3")
        guard let location = locationManger.location?.coordinate else {
            //TODO: Inform the user we don't have their location
            return
        }
        network.returnQuery(accessKey: myAccessKey ?? "") { travel in
            var usersPositions = travel["position"] as! [[CLLocationDegrees]]
            let userCount = travel["userCount"] as! Int
            var loop = 0
            while loop < userCount {
                if loop != self.setIndexNum {
                    let coordinate = usersPositions[loop]
                    let coord2D = CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1])
                    //myAnnotations[loop].coordinate = coord2D
                    if self.userAnnotations[loop].shown {
                        print("Animating annotation")
                        UIView.animate(withDuration: 0.75) {
                            self.userAnnotations[loop].coordinate = coord2D
                        }
                    } else {
                        print("Showing annotations")
                        self.userAnnotations[loop].shown = true
                        self.mapView.addAnnotation(self.userAnnotations[loop])
                    }
                } else {
                    let myPos = [location.latitude, location.longitude]
                    usersPositions[self.setIndexNum ?? 0] = myPos
                    travel["position"] = usersPositions
                }
                loop += 1
            }
            travel.saveInBackground()
        } failure: { error in
            print("Error: \(error.localizedDescription)")
        }

        /*
        
        network.returnQuery(accessKey: myAccessKey ?? "") { travel in
            var usersPositions = travel["position"] as! [[CLLocationDegrees]]
            let userCount = travel["userCount"] as! Int
            let myAnnotations = Array(repeating: MKPointAnnotation(), count: userCount)
            //self.userAnnotations = [GuestAnnotation].init(repeating: GuestAnnotation(location: nil), count: userCount)
            let test = self.setUpArrayAnnotations(userCount: userCount)
            var loop = 0
            while loop < userCount {
                if loop != self.setIndexNum {
                    let coordinate = usersPositions[loop]
                    let coord2D = CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1])
                    //myAnnotations[loop].coordinate = coord2D
                    self.userAnnotations![loop].coordinate = coord2D
                    if test {
                        self.removeAnnotations()
                        self.mapView.addAnnotation(self.userAnnotations?[loop] as! MKAnnotation)
                    } else {
                        UIView.animate(withDuration: 0.2) {
                            self.userAnnotations![loop].coordinate = coord2D
                        }
                    }
                } else {
                    let myPos = [location.latitude, location.longitude]
                    usersPositions[self.setIndexNum] = myPos
                    travel["position"] = usersPositions
                }
                loop += 1
            }
            travel.saveInBackground { success, error in
                if success {
                    print("Success indeed :3")
                } else if error != nil {
                    print("Something went wrong :( \(error?.localizedDescription)")
                }
            }
            
        } failure: { error in
            print("Error: \(error.localizedDescription)")
        }*/

        /*
        removeAnnotations()
        var usersPositions = travelQuery!["position"] as! [[CLLocationDegrees]]
        let userCount = travelQuery!["userCount"] as! Int
        let myAnnotations = Array(repeating: MKPointAnnotation(), count: userCount)
        var loop = 0
        while loop < usersPositions.count {
            if loop != setIndexNum {
                let coordinate = usersPositions[loop]
                let coord2D = CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1])
                myAnnotations[loop].coordinate = coord2D
                self.mapView.addAnnotation(myAnnotations[loop])
                loop += 1
            } else {
                let myPos = [location.latitude, location.longitude]
                usersPositions[setIndexNum] = myPos
                travelQuery!["position"] = usersPositions
            }
        }
        travelQuery!.saveInBackground() */
        /*
        network.liveLocationUpdates(accessKey: myAccessKey ?? "") { travel in
            var usersPositions = travel["position"] as! [[CLLocationDegrees]]
            let userCount = travel["userCount"] as! Int
            //let myCount = userCount.last?.last!
            //print("My Count \(myCount!)")
            let myAnnotations = Array(repeating: MKPointAnnotation(), count: userCount)
            
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
            var loop = 0
            while loop < usersPositions.count {
                if loop != self.setIndexNum {
                    let coordinate = usersPositions[loop]
                    let coord2D = CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1])
                    myAnnotations[loop].coordinate = coord2D
                    self.mapView.addAnnotation(myAnnotations[loop])
                    loop += 1
                } else {
                    let myPos = [location.latitude, location.longitude]
                    usersPositions[self.setIndexNum] = myPos
                    travel["position"] = usersPositions
                }
            }
            // update my locaiton on parse
            //let myPos = [location.latitude, location.longitude]
            //print("Index :\(self.setIndexNum!)")
            //usersPositions[self.setIndexNum] = myPos
            //travel["position"] = usersPositions
            travel.saveInBackground()
            
        } failure: { error in
            print("Error: \(error)")
        }*/

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
            
            print("user pin co-ordinate :",previousLocation.coordinate.latitude, previousLocation.coordinate.longitude)
            
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
