//
//  AlertService.swift
//  SpotOn
//
//  Created by My Mac on 5/6/21.
//

import UIKit

class AlertService{
    
    func alert(me : HomeViewController) -> RequestViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let alertVC = storyboard.instantiateViewController(identifier: "AlertVc") as! RequestViewController
        alertVC.generateToHomeDelegate = me
        
        return alertVC
    }
}
