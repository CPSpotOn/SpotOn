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
    
    
    //TODO: Add any required variables
    let locationManger = CLLocationManager()
    let zoomMagnitude : Double = 1000; // Zoomed in a little more, prev was 10000
    var weatherManager = WeatherManager() //Chris added this
    var previousLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //floating button setUp
        let floatingButton = FloatingButton(controller: self)
        floatingButton.addButtons(with: pinImageView)
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
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
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
}

// MARK:- CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate{
    
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
                    self.geoTestLabel.text = "\(streetNumber) \(streetName)"
                }
            }
        }
    }
}
