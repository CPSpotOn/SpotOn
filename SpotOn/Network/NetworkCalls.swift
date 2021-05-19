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
    func returnQuery(accessKey: String, success: @escaping (PFObject) -> (), failure: @escaping (Error) -> ()) {
        let query = PFQuery(className: queryName)
        query.whereKey("access", equalTo: accessKey)
        query.findObjectsInBackground { objects, error in
            if error != nil {
                failure(error!)
            } else if success != nil {
                success(objects!.last!)
            }
        }
    }
    func userJoinedSession(accessKey: String, success: @escaping (PFObject) -> (), failure: @escaping (Error) -> ()) {
        let query = PFQuery(className: queryName)
        query.whereKey("access", equalTo: accessKey)
        print("Access key: \(accessKey)")
        //query.whereKey("author", notEqualTo: PFUser.current()!)
        //query.includeKey(accessKey)
        //query.includeKey(accessKey)
        query.findObjectsInBackground { objects, error in
            if error != nil {
                failure(error!)
            } else if success != nil {
                success(objects!.last!)
            }
        }
    }
    func liveLocationUpdates(accessKey: String, success: @escaping(PFObject) -> (), failure: @escaping(Error) ->()) {
        let query = PFQuery(className: queryName)
        query.whereKey("access", equalTo: accessKey)
        //query.whereKey("author", notEqualTo: PFUser.current()!)
        query.findObjectsInBackground { objects, error in
            if error != nil {
                failure(error!)
            } else {
                success(objects![0])
            }
        }

    }
}

