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

class HomeViewController: UIViewController {
    //MARK:- Variables
    //TODO: Connect all the outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var geoTestLabel: UILabel!
    
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var dummyView: UIView!
    
    
    //TODO: Add any required variables
    let locationManger = CLLocationManager()
    let zoomMagnitude : Double = 1000; // Zoomed in a little more, prev was 10000
    let zoomMagnitudeAddress : Double = 100; // Zoomed in a little more, prev was 10000
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
    var places : [SearchModel] = []
    var searchManager = SearchLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserTrackingButtonAndScaleView()
        searchVc.searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpSettings()
        setUpSearchVC()
        self.title = "Home"
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
        searchManager.delegate = self
        //showClosestUsers()
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
    
    
    //constraint for FLoating Action Button
    func setConstraints(floatingButton : FloatingButton){
        //constraints
        //floaty.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        floatingButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        floatingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToSettings" {
            if let settingsVC = segue.destination as? SettingsViewController{
                settingsVC.settingsDelegate = self
            }
        }
    }
}

extension HomeViewController : SettingsProtocol{
    func onSettingsChanged() {
        print("on Settings Changed")
        
        DispatchQueue.main.async {
            self.setUpSettings()
            
        }
    }
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
    
    func zoomInTo(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let zoomInLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion.init(center: zoomInLocation, latitudinalMeters: zoomMagnitudeAddress, longitudinalMeters: zoomMagnitudeAddress)
        mapView.setRegion(region, animated: true)
        pinImageView.isHidden = false
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
        timer = Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(getLocationsUpdates), userInfo: nil, repeats: true)
    }
    
    /*
     A scheduler that delays the app for 2.5s
     */
    func scheduledTimerWithTimeIntervalWaiting() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { timer in
            print("Waiting.......")
        })
    }
    
    //weatherManager SetLink is called but not updating
    func setUpSettings() {
        settings.getUserDefaults()
        let transport = settings.getTransport()
        let unit = settings.getUnit()
        print("transport :",transport as Any, "unit :",unit as Any)
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
                print("Changing link to SI")
                weatherManager.setLink(link: "https://api.openweathermap.org/data/2.5/weather?appid=90d68b60af6b20b1c2976096fefb8a9b&units=metric")
                
            } else if unit! == "Imperial" {
                print("Changing link to Imperial")
                weatherManager.setLink(link: "https://api.openweathermap.org/data/2.5/weather?appid=90d68b60af6b20b1c2976096fefb8a9b&units=imperial")
            }
        }
        let center = getCenterLocation(for: mapView)
        weatherManager.fetchWeather(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude)
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
    
    func setupUserTrackingButtonAndScaleView() {
        mapView.showsUserLocation = true
        
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: dummyView.topAnchor, constant: 42),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            
        ])
        
        
        DispatchQueue.main.async {
            self.mapView.showsScale = false
            let scale = MKScaleView(mapView: self.mapView)
            //        scale.legendAlignment = .trailing
            scale.translatesAutoresizingMaskIntoConstraints = false
            self.mapView.addSubview(scale)
        }
        
    }
    
    func setUpSearchVC() {
        searchVc.searchResultsUpdater = self
        navigationItem.searchController = searchVc
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
    
    /* Creates a query/object for hosting a multi user travelling session
     Object create contains infomation with keyValues:
     userCount: Contains user count - 1 denoting their index
     startCoordinates: Contains starting position from which navegation will be calculated
     destinationCoordinates: Contains destionation coordinate
     access: Secret random 6 digit access key
     author: Pointer to host
     names: Array of the names of users in the session
     position: Array of position for each user on map.
     Return: Void
     */
    func getDirectionForGroupSession(accessKey: String, inSession: Bool) {
        if !inSession {
            //make sure we got user location
            guard let location = locationManger.location?.coordinate else {
                //TODO: Inform the user we don't have their location
                return
            }
            //Create query object
            print("Creating Query")
            network.createLiveQuery { travel in
                //travel is PFObject
                //set initial index for host
                self.setIndexNum = 0
                //get user's username
                let username = self.myUser.username!
                //assign values to column on object
                travel["access"] = accessKey
                travel["author"] = PFUser.current()!
                travel["names"] = [self.myUser["name"] as! String]
                //obtain current user's location
                let myCoordinates = [location.latitude, location.longitude]
                let destinationCoordinates = self.getDestinationCoordinates()
                let aDestinationCoordinates = [destinationCoordinates.latitude, destinationCoordinates.longitude]
                //assign user's location to column of object
                travel["startCoordinates"] = myCoordinates
                travel["destinationCoordinates"] = aDestinationCoordinates
                //set user count to zero denotating index for each user
                travel["userCount"] = 0
                travel["position"] = [[location.latitude, location.longitude]]
                travel["usernames"] = [username]
                
                //check for transportation method
                if self.transportMethod == .automobile {
                    travel["method"] = "Car"
                } else if self.transportMethod == .walking {
                    travel["method"] = "Walk"
                }
                //save changed and update objects data
                travel.saveInBackground { success, error in
                    if success {
                        print(success)
                    } else {
                        print("Error: \(String(describing: error?.localizedDescription))")
                    }
                }
                //delay
                DispatchQueue.main.async {
                    //print("Waiting 4.5s in getDirectionsForGroup")
                    self.scheduledTimerWithTimeIntervalWaiting()
                }
                self.getImageURL(username: self.myUser.username!)
                //self.userAnnotations[setIndexNum].userImage = self.imageUser[setIndexNum]
                print("Query Created :D")
            }
            
            //create request for direction
            let request = createDirectionRequest(from: location)
            let directions = MKDirections(request: request)
            resetMapview(withNew: directions)
            
            //plots reponse from direction
            directions.calculate { response, error in
                //TODO: Handle error if needed
                guard let response = response else { return }
                //for multiple routes
                for route in response.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.userTrackingMode = .follow
                }
            }
            //hide lables
            self.title = myAccessKey
            pinImageView.isHidden = true
            print("Sent directions")
        }
    }
    
    /* Joins  query object hosting a multi user travelling session
     Object joined contains infomation with key values:
     userCount: Contains user count - 1 denoting their index. It gets updated with +1
     startCoordinates: Contains starting position from which navegation will be calculated
     destinationCoordinates: Contains destionation coordinate
     access: Secret random 6 digit access key
     author: Pointer to host
     names: Array of the names of users in the session. It gets updated with the user joining the session
     position: Array of position for each user on map.. It gets updated with the user joining the session location
     Return: Void
     */
    func joinGroupSession() {
        guard let location = locationManger.location?.coordinate else {
            //TODO: Inform the user we don't have their location
            return
        }
        mapView.register(GuestAnnotationMarkerView.self,forAnnotationViewWithReuseIdentifier:MKMapViewDefaultAnnotationViewReuseIdentifier)
        //calls network to return query passing the access key
        network.returnQuery(accessKey: myAccessKey ?? "") { travel in
            print("Query joined :3")
            //loads data from query
            var userCount = travel["userCount"] as! Int
            var namesArray = travel["names"] as! [String]
            var usernames =  travel["usernames"] as! [String]
            var positions = travel["position"] as! [[CLLocationDegrees]]
            let startCoordinates = travel["startCoordinates"] as! [CLLocationDegrees]
            let destinationCoordinates = travel["destinationCoordinates"] as! [CLLocationDegrees]
            var arrayOfNames = travel["names"] as! [String]
            let method = travel["method"] as! String
            let startCoordinatesCLL = CLLocationCoordinate2D(latitude: startCoordinates[0] , longitude: startCoordinates[1] )
            let destinationCoordinatesCLL = CLLocationCoordinate2D(latitude: destinationCoordinates[0] , longitude: destinationCoordinates[1] )
            
            //loads traporpation method
            if method == "Car" {
                self.transportMethod = .automobile
            } else if method == "Walk" {
                self.transportMethod = .walking
            }
            //creates request with loaded data
            let request = self.createDirectionRequestForOthers(from: startCoordinatesCLL, to: destinationCoordinatesCLL)
            
            //set index for joining user
            self.setIndexNum = userCount + 1
            //add current values to usernames and names array
            usernames.append(self.myUser.username!)
            namesArray.append(self.myUser["name"] as! String)
            //update query column values
            travel["names"] = namesArray
            userCount = self.setIndexNum
            travel["userCount"] = userCount
            positions.append([location.latitude, location.longitude])
            travel["position"] = positions
            travel["usernames"] = usernames
            arrayOfNames.append(self.myUser["name"] as! String)
            print(arrayOfNames)
            travel["names"] = arrayOfNames
            
            //updates annonation array for user
            self.userAnnotations.removeAll()
            var loop = 0
            while loop < usernames.count {
                let annotation = GuestAnnotation(title: namesArray[loop], locationName: nil, discipline: String(loop), coordinate: nil, subtitle: usernames[loop])
                annotation.isShown = false
                self.userAnnotations.append(annotation)
                loop += 1
            }
            //creates direction request
            let directions = MKDirections(request: request)
            //resets map if any gps nav was active
            self.resetMapview(withNew: directions)
            //plot gps nav
            directions.calculate { response, error in
                //TODO: Handle error if needed
                guard let response = response else { return }
                //for multiple routes
                for route in response.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.userTrackingMode = .follow
                }
            }
            //saves data back on parse
            travel.saveInBackground { success, error in
                if success {
                    print(success)
                } else {
                    print("Error: \(String(describing: error?.localizedDescription))")
                }
            }
            print(self.imageUser)
            self.pinImageView.isHidden = true
            print("Saved stuff :3")
            
        } failure: { error in
            print("Error \(error.localizedDescription)")
        }
        //Add new  user annotation
        let annonation = GuestAnnotation(title: nil, locationName: nil, discipline: nil, coordinate: nil, subtitle: nil)
        //var user = PFUser.current()!
        annonation.isShown = false
        //annonation.title = myUser["name"] as! String
        userAnnotations.append(annonation)
        //accessLabel.text = "Access: \(myAccessKey)"
        scheduledTimerWithTimeIntervalWaiting()
    }
    
    /* Updates  query object hosting a multi user travelling session
     Object joined contains infomation with key values:
     userCount: Contains user count - 1 denoting their index. It gets updated with +1
     startCoordinates: Contains starting position from which navegation will be calculated
     destinationCoordinates: Contains destionation coordinate
     access: Secret random 6 digit access key
     author: Pointer to host
     names: Array of the names of users in the session. It gets updated with the user joining the session
     position: Array of position for each user on map.. It gets updated with the user joining the session location
     Return: Void
     */
    @objc func getLocationsUpdates() {
        print("Getting updates :3")
        guard let location = locationManger.location?.coordinate else {
            //TODO: Inform the user we don't have their location
            return
        }
        network.returnQuery(accessKey: myAccessKey ?? "") { travel in
            var usersPositions = travel["position"] as! [[CLLocationDegrees]]
            let userCount = travel["userCount"] as! Int
            let namesArray = travel["names"] as! [String]
            let usernames =  travel["usernames"] as! [String]
            
            if self.userAnnotations.count < namesArray.count {
                var loop = self.userAnnotations.count
                while loop < usernames.count {
                    let annotation = GuestAnnotation(title: namesArray[loop], locationName: nil, discipline: String(loop), coordinate: nil, subtitle: usernames[loop])
                    annotation.isShown = false
                    self.userAnnotations.append(annotation)
                    loop += 1
                }
            }
            if self.imageUser.count < namesArray.count {
                var loop = self.imageUser.count
                while loop < usernames.count {
                    self.getImageURL(username: usernames[loop])
                    loop += 1
                }
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
                    usersPositions[self.setIndexNum ] = myPos
                    travel["position"] = usersPositions
                }
                loop += 1
            }
            travel.saveInBackground { success, error in
                if success {
                    print(success)
                } else {
                    print("Error: \(String(describing: error?.localizedDescription))")
                }
            }
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
            print("conditionID: ", weather.conditionId)
            self.tempImageView.image = UIImage(named: weather.conditionName)
        }
    }
    
    func didFailWithError(error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK:- MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? GuestAnnotation else {
            return nil
        }
        
        // 3
        let identifier = "guest"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
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
            
            guard center.distance(from: previousLocation) > 5 else { return }
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
                        self.searchVc.searchBar.text = "\(streetNumber) \(streetName)"
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
    /*
     private func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
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
     annonationView?.image = imageUser[self.setIndexNum]
     return annonationView
     }*/
}

// MARK:- GeneratedToHomeDelegate
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

// MARK:- UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let resultVC = searchController.searchResultsController as? SearchResultViewController
        resultVC?.delegate = self
        DispatchQueue.main.async {
            print(self.places)
            resultVC?.update(with: self.places)
        }
    }
}

// MARK:- UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let a = searchBar.text?.components(separatedBy: " ")
        searchManager.fetchAddress(splitAddress: a!)
    }
}

// MARK:- SearchManagerDelegate
extension HomeViewController: SearchManagerDelegate {
    func didUpdateAddress(_ searchingManager: SearchLocation, search: [SearchModel]) {
        DispatchQueue.main.async {
            self.places = search
            self.updateSearchResults(for: self.searchVc)
        }
        
    }
    func didFailWithErrorSearch(error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

extension HomeViewController: SearchResultDelegate {
    func didTapPlace(lat: CLLocationDegrees, lon: CLLocationDegrees, address: String) {
        DispatchQueue.main.async {
            self.zoomInTo(lat: lat, lon: lon)
            self.searchVc.searchBar.text = address
        }
    }
}
