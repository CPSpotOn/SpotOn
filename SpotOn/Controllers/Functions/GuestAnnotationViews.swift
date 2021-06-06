//
//  GuestAnnotationViews.swift
//  SpotOn
//
//  Created by Christopher Mena on 6/4/21.
//

import Foundation
import MapKit

class GuestAnnotationMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            // 1
            guard let guest = newValue as? GuestAnnotation else {
                return
            }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            // 2
            markerTintColor = guest.markerTintColor
            glyphImage = guest.userImage
            if let letter = guest.discipline?.first {
                glyphText = String(letter)
            }
        }
    }
}
