//
//  GuestAnnotation.swift
//  SpotOn
//
//  Created by Christopher Mena on 5/14/21.
//

import Foundation
import MapKit

class GuestAnnotation : NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String!
    var subtitle: String!
    var shown: Bool!

    init(location coord:CLLocationCoordinate2D?) {
        self.coordinate = coord ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        super.init()
    }
}
