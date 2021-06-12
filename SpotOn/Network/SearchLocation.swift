//
//  SearchLocation.swift
//  SpotOn
//
//  Created by Christopher Mena on 6/11/21.
//

import Foundation
import CoreLocation

protocol SearchManagerDelegate {
    func didUpdateAddress(_ searchingManager: SearchLocation, search: [SearchModel])
    func didFailWithErrorSearch(error: Error)
}

struct SearchLocation {
    var baseUrl = "https://api.tomtom.com/search/2/search/"
    var delegate: SearchManagerDelegate?
    func fetchAddress(splitAddress: [String]) {
        var dUrl = baseUrl
        var count = 0
        while count < splitAddress.count {
            if count < splitAddress.count - 2 {
                dUrl += "\(splitAddress[count])%20"
                count += 1
            } else {
                dUrl += splitAddress[count]
                count += 1
            }
        }
        print(baseUrl)
        //Complete url
        dUrl += ".json?key=NfI1Gfw25r9H1HPzOk4eWFPHudkd1C0d"
        print(dUrl)
        performRequest(withUrl: dUrl)
    }
    
    func performRequest(withUrl: String) {
        print("Starting request")
        //create url
        if let url = URL(string: withUrl) {
            // Start networking session
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                // If error, inform the protocol of error
                if error != nil {
                    print("Sending error")
                    self.delegate?.didFailWithErrorSearch(error: error!)
                    return
                }
                // If data exist, parse data
                if let safeData = data {
                    print("Safe data :D")
                    if let search = self.parseJSON(safeData) {
                        self.delegate?.didUpdateAddress(self, search: search)
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK:- Parse weather data into a weather model data
    func parseJSON(_ searchData: Data) -> [SearchModel]? {
        print("Parsing data")
        // Initialize a decoder
        let decoder = JSONDecoder()
        // Decode data
        do {
            print("Decoding")
            // TRY decoding data using 'SearchrData' format fromsearchData
            let decodedData = try decoder.decode(SearchData.self, from: searchData)
            var aSearch : [SearchModel] = []
            for inData in decodedData.results {
                let lat = inData.position.lat
                let lon = inData.position.lon
                let address = inData.address.freeformAddress
                
                let search = SearchModel(latitude: lat, longitude: lon, freeformAddress: address)
                aSearch.append(search)
            }
            return aSearch
            
        } catch {
            // If error catch, inform the protocol of error
            print("Failed decofing :(")
            delegate?.didFailWithErrorSearch(error: error)
            return nil
        }
    }
}
