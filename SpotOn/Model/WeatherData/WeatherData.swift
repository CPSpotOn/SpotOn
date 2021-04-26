//
//  WeatherData.swift
//  SpotOn
//
//  Created by Christopher Mena on 4/13/21.
//

import Foundation

/**
 Struct to hold key values for weather
 - name: name of city/location
 - main: sturct holding "main" dictionary from weather data
 - weather: array of weather data
 */
struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
