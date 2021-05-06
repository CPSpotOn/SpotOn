//
//  AlertService.swift
//  SpotOn
//
//  Created by My Mac on 5/6/21.
//

import UIKit

class AlertService{
    
    func alert() -> AlertViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let alertVC = storyboard.instantiateViewController(identifier: "AlertVc") as! AlertViewController
        
        return alertVC
    }
}
