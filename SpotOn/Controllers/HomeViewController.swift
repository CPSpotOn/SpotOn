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
import Alamofire
import AlamofireImage
import FloatingPanel

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
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    
    
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
    var userAnnotations = [GuestAnnotation()]
    var userTrackCount : Int = 0
    var myUser = PFUser.current()!
    var accessKey = "";
    var settings = AppSetting()
    var transportMethod = MKDirectionsTransportType()
    var centerToggel = false
    var imageUser = [UIImage]()
    var floatingVC : FloatingPanelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFloatingPanel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpSettings()
        self.title = "Home"
        userAnnotations[0].isShown = false
        //floating button setUp
        let floatingButton = FloatingButton(controller: self)
        floatingButton.test = self
        floatingButton.addButtons(with: pinImageView)
        
        infoStackView.backgroundColor = .clear
        
        //invite or accept
        floatingButton.addItem("Connect", icon: UIImage(named: "connect")){ item in
            let alertVc = AlertService().alert(me: self)
            alertVc.modalPresentationStyle = .overCurrentContext
            alertVc.providesPresentationContextTransitionStyle = true
            alertVc.definesPresentationContext = true
            alertVc.modalTransitionStyle = .crossDissolve
            self.present(alertVc, animated: true, completion: nil)
            
        }
        
//        floatingButton.addItem("Center", icon: UIImage(systemName: "rectangle.center.inset.fill")) { item in
//            if self.centerToggel {
//                self.mapView.userTrackingMode = .none
//                self.centerToggel = false
//            } else {
//                self.mapView.userTrackingMode = .follow
//                self.centerToggel = true
//            }
//        }
        
        view.addSubview(floatingButton)
        setConstraints(floatingButton: floatingButton)
        setWeatherManager()
        weatherManager.performRequest(with: weatherManager.weatherURL)
        checkLocationServices()
        overrideUserInterfaceStyle = .light //light mode by default
        
        showClosestUsers()
        
        
        network.imagesQuery(username: myUser.username!) { user in
            if user != nil {
                DispatchQueue.main.async {
                    let imageFile = user["image"] as! PFFileObject
                    let imageUrl = imageFile.url!
                    //let url = URL(string: imageUrl)!
                    self.downloadImage(from: URL(string: imageUrl)!)
                }
            }
        } failure: { error in
            print("Error: \(error.localizedDescription)")
        }

        
    }
    
    //center toggle
    @IBAction func onTapCenter(_ sender: Any) {
        if self.centerToggel {
            self.mapView.userTrackingMode = .none
            self.centerToggel = false
        } else {
            self.mapView.userTrackingMode = .follow
            self.centerToggel = true
        }
    }
    
    
    //click listener for settings
    
    @IBAction func onSettinsTap(_ sender: Any) {
        print("Settings")
        let settingsPanvelVC = FloatingPanelController()
        settingsPanvelVC.delegate = self
        let settingsVC = storyboard?.instantiateViewController(identifier: "Settings") as? SettingsViewController
        settingsPanvelVC.set(contentViewController: settingsVC)
     
        settingsPanvelVC.addPanel(toParent: self)
        
        
        settingsPanvelVC.backdropView.dismissalTapGestureRecognizer.isEnabled = true
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
    
    
}


///Floatng Panel View Controller
extension HomeViewController : FloatingPanelControllerDelegate{
    
    func loadFloatingPanel(){
        floatingVC = FloatingPanelController()
        floatingVC.delegate = self
        
        let OptionVC = storyboard?.instantiateViewController(identifier: "optionsVC") as? OptionsViewController
        
        floatingVC.set(contentViewController: OptionVC)
        floatingVC.addPanel(toParent: self)
        floatingVC.layout = MyFloatingPanelLayout()
        floatingVC.contentMode = .fitToBounds
        floatingVC.invalidateLayout()
    }
    
    class MyFloatingPanelLayout : FloatingPanelLayout{
        let position: FloatingPanelPosition = .bottom
           let initialState: FloatingPanelState = .tip
           var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
                        .full: FloatingPanelLayoutAnchor(absoluteInset: 5.0, edge: .top, referenceGuide: .safeArea),
                        .half: FloatingPanelLayoutAnchor(fractionalInset: 0.3, edge: .bottom, referenceGuide: .safeArea),
                        .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
                    ]
           }
    }
    
}

//end of floating panel


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
        accessLabel.isHidden = true
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
    
    /*
     Setup wWeather Manager Delegate
     */
    func setWeatherManager() {
        self.weatherManager.delegate = self
    }
    
    func alert() {
        let alert = UIAlertController(title: "Did not allow SpotOn to know your location!", message: "It's recommended you allow SpotOn to know your location to fully utilize its features. Please go to settings and allow SpotOn to know your location.", preferredStyle: .alert)
        self.present(alert, animated: true)
    }
    
    /*
     A scheduler that calls the function getLocationsUpdates every 0.25s
     */
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(getLocationsUpdates), userInfo: nil, repeats: true)
    }
    
    /*
     A scheduler that delays the app for 2.5s
     */
    func scheduledTimerWithTimeIntervalWaiting() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { timer in
            print("Waiting.......")
        })
    }
    
    func setUpSettings() {
            settings.getUserDefaults()
            var transport = settings.getTransport()
            var unit = settings.getUnit()
            if transport != nil {
                //TODO set transport
                if transport! == "Car" {
                    transportMethod = .automobile
                } else if transport! == "Walk" {
                    transportMethod = .walking
                }
            } else {
                transportMethod = .automobile
            }
            if unit != nil {
                //TODO: set unit
                if unit! == "SI" {
                    weatherManager.setLink(link: "https://api.openweathermap.org/data/2.5/weather?appid=90d68b60af6b20b1c2976096fefb8a9b&units=metric")
                } else if unit! == "Imperial" {
                    weatherManager.setLink(link: "https://api.openweathermap.org/data/2.5/weather?appid=90d68b60af6b20b1c2976096fefb8a9b&units=imperial")
                }
            }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.imageView.image = UIImage(data: data)
                self?.imageUser.append(UIImage(data: data)!)
            }
        }
    }
    
    func getImageURL(username: String){
        network.imagesQuery(username: username) { user in
            //image
            let image = user["image"] as! PFFileObject
            let imageUrl = image.url!
            let url = URL(string: imageUrl)!
            self.downloadImage(from: url)
            
        } failure: { error in
            print("Error: \(error.localizedDescription)")
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
            self.mapView.userTrackingMode = .follow

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
    func getDirectionForGroupSession(accessKey: String, inSession: Bool) {
        if !inSession {
            //make sure we got user location
            guard let location = locationManger.location?.coordinate else {
                //TODO: Inform the user we don't have their location
                return
            }
            print("Creating Query")
            network.createLiveQuery { travel in
                self.setIndexNum = 0
                var username = self.myUser.username!
                travel["access"] = accessKey
                travel["author"] = PFUser.current()!
                travel["joining"] = false
                travel["names"] = [self.myUser["name"] as! String]
                //travel["objectId"] = accessKey
                let myCoordinates = [location.latitude, location.longitude]
                let destinationCoordinates = self.getDestinationCoordinates()
                let aDestinationCoordinates = [destinationCoordinates.latitude, destinationCoordinates.longitude]
                travel["startCoordinates"] = myCoordinates
                travel["destinationCoordinates"] = aDestinationCoordinates
                travel["userCount"] = 0
                travel["position"] = [[location.latitude, location.longitude]]
                travel["usernames"] = [username]
                if self.transportMethod == .automobile {
                    travel["method"] = "Car"
                } else if self.transportMethod == .walking {
                    travel["method"] = "Walk"
                }
                // var userCount = travel["userCount"] as! [[PFUser: Int]]
                travel.saveInBackground { success, error in
                    if error != nil {
                        print("Error: \(error?.localizedDescription)")
                    } else if success != nil {
                        print("Saved")
                    }
                }
                //print(travel.objectId)
                DispatchQueue.main.async {
                    //print("Waiting 4.5s in getDirectionsForGroup")
                    self.scheduledTimerWithTimeIntervalWaiting()
                }
                self.getImageURL(username: self.myUser.username!)
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
                    self.mapView.userTrackingMode = .follow
                }
            }
            accessLabel.isHidden = false
            //accessLabel.text = "Access: \(myAccessKey)"
            self.title = myAccessKey
            pinImageView.isHidden = true
            print("Sent directions")
        }
    }
    
    func joinGroupSession() {
        guard let location = locationManger.location?.coordinate else {
            //TODO: Inform the user we don't have their location
            return
        }
        network.returnQuery(accessKey: myAccessKey ?? "") { travel in
            print("Query joined :3")
            var userCount = travel["userCount"] as! Int
            var namesArray = travel["names"] as! [String]
            var usernames =  travel["usernames"] as! [String]
            var positions = travel["position"] as! [[CLLocationDegrees]]
            let startCoordinates = travel["startCoordinates"] as! [CLLocationDegrees]
            let destinationCoordinates = travel["destinationCoordinates"] as! [CLLocationDegrees]
            var arrayOfNames = travel["names"] as! [String]
            var method = travel["method"] as! String
            let startCoordinatesCLL = CLLocationCoordinate2D(latitude: startCoordinates[0] , longitude: startCoordinates[1] )
            let destinationCoordinatesCLL = CLLocationCoordinate2D(latitude: destinationCoordinates[0] , longitude: destinationCoordinates[1] )
            
            if method == "Car" {
                self.transportMethod = .automobile
            } else if method == "Walk" {
                self.transportMethod = .walking
            }
            let request = self.createDirectionRequestForOthers(from: startCoordinatesCLL, to: destinationCoordinatesCLL)
            
            self.setIndexNum = userCount + 1
            usernames.append(self.myUser.username!)
            namesArray.append(self.myUser["name"] as! String)
            travel["names"] = namesArray
            travel["joining"] = true
            userCount = self.setIndexNum
            travel["userCount"] = userCount
            positions.append([location.latitude, location.longitude])
            travel["position"] = positions
            travel["usernames"] = usernames
            arrayOfNames.append(self.myUser["name"] as! String)
            print(arrayOfNames)
            travel["names"] = arrayOfNames
            let directions = MKDirections(request: request)
            
            self.resetMapview(withNew: directions)
            
            directions.calculate { response, error in
                //TODO: Handle error if needed
                guard let response = response else { return }
                //for multiple routes
                for route in response.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.userTrackingMode = .follow
                }
            }
            
            print(self.imageUser)
            self.pinImageView.isHidden = true
            print("Sent directions")
            travel.saveInBackground()
            print("Saved stuff :3")
            
        } failure: { error in
            print("Error \(error.localizedDescription)")
        }
        //Add new  user annotation
        var annonation = GuestAnnotation()
        //var user = PFUser.current()!
        annonation.isShown = false
        //annonation.title = myUser["name"] as! String
        userAnnotations.append(annonation)
        accessLabel.isHidden = false
        //accessLabel.text = "Access: \(myAccessKey)"
        scheduledTimerWithTimeIntervalWaiting()
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
            var joining = travel["joining"] as! Bool
            var namesArray = travel["names"] as! [String]
            var usernames =  travel["usernames"] as! [String]
            
            while self.userAnnotations.count < namesArray.count {
                var annonation = GuestAnnotation()
                annonation.isShown = false
                self.userAnnotations.append(annonation)
            }
            if self.imageUser.count < usernames.count {
                self.imageUser.removeAll()
                for name in usernames {
                    self.getImageURL(username: name)
                }
            }
            if joining {
                
                travel["joining"] = false
            }
            
            var loop = 0
            while loop <= userCount {
                if loop != self.setIndexNum {
                    let coordinate = usersPositions[loop]
                    let coord2D = CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1])
                    //myAnnotations[loop].coordinate = coord2D
                    //Check if index exist
                    let exist = self.userAnnotations.indices.contains(loop)
                    if exist {
                        if self.userAnnotations[loop].isShown {
                            print("Animating annotation")
                            UIView.animate(withDuration: 0.75) {
                                self.userAnnotations[loop].coordinate = coord2D
                            }
                        } else {
                            print("Showing annotations")
                            self.userAnnotations[loop].isShown = true
                            self.mapView.addAnnotation(self.userAnnotations[loop])
                        }
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
            let unitM = self.settings.getUnit()
            if unitM != nil {
                if unitM! == "SI" {
                    self.tempLabel.text = weather.temperatureString + "°C"
                } else {
                    self.tempLabel.text = weather.temperatureString + "°F"
                }
            } else {
                self.tempLabel.text = weather.temperatureString + "°F"
            }
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
        self.centerToggel = false
        //self.mapView.userTrackingMode = .none
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
                        
                        ///pin addess value is changed here
                        //self.searchTextField.text = "\(streetNumber) \(streetName)"
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
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annonationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annonationView == nil {
            // Create annonation
            annonationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annonationView?.canShowCallout = true
        } else {
            annonationView?.annotation = annotation
        }
        let cpa = MKPointAnnotation() as! GuestAnnotation
        cpa.imageView = imageUser[setIndexNum]
        annonationView?.image = imageUser[self.setIndexNum]
         return annonationView
     }
}

extension HomeViewController : GeneratedToHomeDelegate{
    func gotoHomeAndAction(access: String, createSession: Bool) {
        myAccessKey = access
        if createSession {
            getDirectionForGroupSession(accessKey: myAccessKey!, inSession: inOnlineSession)
        } else {
            joinGroupSession()
        }
        scheduledTimerWithTimeInterval()
    }
}
