//
//  GuestAnnotation.swift
//  SpotOn
//
//  Created by Christopher Mena on 5/14/21.
//

import Foundation
import MapKit

class GuestAnnotation : NSObject, MKAnnotation {
    //var imageName: UIImage?
    let title: String?
    let subtitle: String?
    let locationName: String?
    let discipline: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var isShown: Bool = false
    
    init(
        title: String?,
        locationName: String?,
        discipline: String?,
        coordinate: CLLocationCoordinate2D?,
        subtitle: String?
    ) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.subtitle = subtitle
        if coordinate != nil {
            self.coordinate = coordinate!
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(), longitude: CLLocationDegrees())
        }
        super.init()
    }
    
    var userImage: UIImage {
        return UIImage(systemName: "car")!
    }
    
    var markerTintColor: UIColor  {
      switch discipline {
      case "1":
        return .red
      case "2":
        return .cyan
      case "3":
        return .blue
      case "4":
        return .purple
      default:
        return .green
      }
    }
}
