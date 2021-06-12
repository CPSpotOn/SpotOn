//
//  SearchData.swift
//  SpotOn
//
//  Created by Christopher Mena on 6/11/21.
//

import Foundation

struct SearchData: Codable {
    let results: [Results]
}


struct Results: Codable {
    let type: String
    let id: String
    let score: Double
    let position: Position
    let address: Address
}
struct Position: Codable {
    let lat: Double
    let lon: Double
}

struct Address: Codable {
    let freeformAddress: String
}
