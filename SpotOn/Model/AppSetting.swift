//
//  AppSetting.swift
//  SpotOn
//
//  Created by Christopher Mena on 5/27/21.
//

import Foundation

struct AppSetting {
    var unit : String?
    var transport : String?
    
    mutating func getUserDefaults() {
        let userD = UserDefaults.standard
        if userD.bool(forKey: "save") {
            unit = userD.string(forKey: "unit") ?? nil
            transport = userD.string(forKey: "transport") ?? nil
        }
    }
    
    func getUnit() -> String? {
        return unit
    }
    func getTransport() -> String? {
        return transport
    }
}
