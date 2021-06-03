//
//  GuestAnnotation.swift
//  SpotOn
//
//  Created by Christopher Mena on 5/14/21.
//

import Foundation
import MapKit

class GuestAnnotation : MKPointAnnotation {
    //var imageName: UIImage?
    var isShown: Bool!
    var imageView: UIImage!
    
    override init() {
        super.init()
    }
}
