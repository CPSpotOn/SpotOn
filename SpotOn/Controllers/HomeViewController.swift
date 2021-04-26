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
    
    
    //TODO: Add any required variables
    let locationManger = CLLocationManager()
    let zoomMagnitude : Double = 10000;
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //floating button
        setFloaty()
        setWeatherManager()
        checkLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

extension HomeViewController{
    //MARK:- Map helper functions
    
    //creates a floating button and sets constraint
    func setFloaty(){
        let floaty = Floaty()
        floaty.translatesAutoresizingMaskIntoConstraints = false
        
        //logsout on click
        floaty.addItem("Logout", icon: UIImage(systemName: "clear")!, handler: { item in
            PFUser.logOut()
            //let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate
            else{
                return
            }
            let main = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
            sceneDelegate.window?.rootViewController = loginViewController
            
            floaty.close()
        })
        
        //segues into Settings from Home
        floaty.addItem("Settings", icon: UIImage(systemName: "gearshape")!, handler: { item in
            self.performSegue(withIdentifier: "homeToSettings", sender: nil)
            floaty.close()
        })
        
        //navigate to Profile from Home
        floaty.addItem("Profile", icon: UIImage(systemName: "person")!, handler: { item in
            self.performSegue(withIdentifier: "homeToProfile", sender: nil)
            floaty.close()
        })
        
        self.view.addSubview(floaty)
        
        //constraints
        //floaty.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        floaty.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        floaty.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floaty.heightAnchor.constraint(equalToConstant: 50).isActive = true
        floaty.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
        
    }
    
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
        locationManger.desiredAccuracy = kCLLocationAccuracyReduced
        locationManger.allowsBackgroundLocationUpdates = true
        locationManger.requestAlwaysAuthorization()
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
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update locations when user move
        print("test")
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: zoomMagnitude, longitudinalMeters: zoomMagnitude)
        weatherManager.fetchWeather(latitude: center.latitude, longitude: center.longitude)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch  manager.authorizationStatus {
            case .authorizedAlways , .authorizedWhenInUse:
                print("always and when in use")
                mapView.showsUserLocation = true
                zoomInUserLocation()
                locationManger.startUpdatingLocation()
                break
            case .notDetermined , .denied , .restricted:
                print("denied")
                alert()
                break
            default:
                print("wow nothing worked")
                break
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK:- WeatherManagerDelegate
extension HomeViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.tempLabel.text = weather.temperatureString + "°"
            self.cityLabel.text = weather.cityName
            self.tempImageView.image = UIImage(named: weather.conditionName)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
