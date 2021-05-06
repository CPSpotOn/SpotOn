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
    func createPost(post post: String, coordinate coordinate: CLLocationDegrees,  from user: PFUser) {
        //TODO: Create post for user
        var postObject = PFObject(className: "Posts")
    }
    func loadPosts(user user: PFUser) -> [String] {
        //TODO: Load posts from network
        return []
    }
    func loadPostsCoordinates(user user: PFUser) -> [CLLocationDegrees] {
        //TODO: Load cooordinate for posts
        return []
    }
    func placePostOnMap(mapView mapView: MKMapView) {
        //TODO: Place posts on map
    }
}
