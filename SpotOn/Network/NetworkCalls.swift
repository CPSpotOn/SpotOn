//
//  NetworkCalls.swift
//  SpotOn
//
//  Created by My Mac on 4/11/21.
//

import Foundation
import Parse
import MapKit
import CoreLocation

//TODO: Add network call methods
struct NetworkCalls {
    let queryName = "LiveTravel"
    func createLiveQuery(success: @escaping (PFObject) ->()) {
        let startUpQuery = PFObject(className: queryName)
        success(startUpQuery)
    }
    func userJoinedSession(accessKey: String, success: @escaping (PFObject) -> (), failure: @escaping (Error) -> ()) {
        let query = PFQuery(className: queryName)
        query.includeKey(accessKey)
        query.findObjectsInBackground { objects, error in
            if error != nil {
                failure(error!)
            } else {
                success(objects![0])
            }
        }
    }
    func userJoinedHelper(session: PFObject, position: CLLocationCoordinate2D) {
        var userCount = session["userCount"] as! [[PFUser: Int]]
        var usersLocation = session["position"] as! [[CLLocationCoordinate2D]]
        let lastCount = userCount.last!
        for (a, b) in lastCount {
            userCount.append([PFUser.current()! : b + 1])
        }
        usersLocation.append([position])
        session["userCount"] = userCount
        session["position"] = usersLocation
        session.saveInBackground { success, error in
            if success {
                print("Saved new data")
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    func liveLocationUpdates(accessKey: String, success: @escaping(PFObject) -> (), failure: @escaping(Error) ->()) {
        let query = PFQuery(className: queryName)
        query.includeKey(accessKey)
        query.findObjectsInBackground { objects, error in
            if error != nil {
                failure(error!)
            } else {
                success(objects![0])
            }
        }
    }
}

