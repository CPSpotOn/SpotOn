//
//  OptionsViewController.swift
//  SpotOn
//
//  Created by William on 6/6/21.
//

import UIKit

class OptionsViewController: UIViewController {

    ///container labels
    @IBOutlet weak var locationContainerView: UIView!
    @IBOutlet weak var connectContainerView: UIView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var goContainerView: UIView!
    
    ///location label which is set based on the current location of the user
    @IBOutlet weak var locationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makeCircleButton()
       
    }
    
    func makeCircleButton(){
        locationContainerView.layer.cornerRadius = 10
        connectContainerView.layer.cornerRadius = connectContainerView.frame.size.width / 2
        
        profileContainerView.layer.cornerRadius = profileContainerView.frame.size.width / 2
        
        pinContainerView.layer.cornerRadius = pinContainerView.frame.size.width / 2
        
        goContainerView.layer.cornerRadius = goContainerView.frame.size.width / 2
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
