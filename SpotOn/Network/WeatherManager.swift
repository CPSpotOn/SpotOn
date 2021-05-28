//
//  WeatherManager.swift
//  SpotOn
//
//  Created by Christopher Mena on 4/26/21.
//
import Foundation
import CoreLocation

/**
 Create Delegate protocol for WeatherManager Struc
 */
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    //OpenWeather API KEY & URL
    var unit = "imperial"
    var weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=90d68b60af6b20b1c2976096fefb8a9b&units=imperial"
    // Delegate
    var delegate: WeatherManagerDelegate?
    
    // MARK:- Fetches weather with coordinates provided
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let completeUrl = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: completeUrl)
    }
    
    // MARK:- Perform request to openweather API
    func performRequest(with urlString: String) {
        // Create url
        if let url = URL(string: urlString) {
            // Start networking session
            let session = URLSession(configuration: .default)
            // Start networking task
            let task = session.dataTask(with: url) { (data, response, error) in
                // If error, inform the protocol of error
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                // If data exist, parse data
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK:- Parse weather data into a weather model data
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        // Initialize a decoder
        let decoder = JSONDecoder()
        // Decode data
        do {
            // TRY decoding data using 'WeatherData' format from weatherData
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            //Assings values from decoded data
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            // Create a 'WeatherModel' with weatherData
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            // Return WeatherModel
            return weather
            
        } catch {
            // If error catch, inform the protocol of error
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    mutating func setLink(link: String) {
        weatherURL = link
    }
}
