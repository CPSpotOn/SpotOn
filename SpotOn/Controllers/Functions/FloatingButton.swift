//
//  FloatingButton.swift
//  SpotOn
//
//  Created by My Mac on 5/2/21.
//

import Foundation
import Floaty
import Parse

protocol Test {
    func run(isHidden : Bool);
}

class FloatingButton : Floaty{
    
    //variables
    var controller : UIViewController!
    var test : Test!
    
    
    init(controller : UIViewController) {
        super.init()
        self.controller = controller
        addButtons()
    }
    
    func addButtons(){
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //logsout on click
        self.addItem("Logout", icon: UIImage(systemName: "clear")!, handler: { item in
            PFUser.logOut()
            //let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate
            else{
                return
            }
            let main = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
            sceneDelegate.window?.rootViewController = loginViewController
            
            self.close()
        })
        
        //segues into Settings from Home
        self.addItem("Settings", icon: UIImage(systemName: "gearshape")!, handler: { item in
            self.controller.performSegue(withIdentifier: "homeToSettings", sender: nil)
            self.close()
        })
        
        //navigate to Profile from Home
        self.addItem("Profile", icon: UIImage(systemName: "person")!, handler: { item in
            self.controller.performSegue(withIdentifier: "homeToProfile", sender: nil)
            self.close()
        })
    }
    
    func addButtons(with imageView : UIImageView){
        //display or hide pin
        self.addItem("Pin", icon: UIImage(systemName: "pin")!) { item in
            if imageView.isHidden == true {
                imageView.isHidden = false
            } else {
                imageView.isHidden = true
            }
        }
        
        self.addItem("Go", icon: UIImage(systemName: "figure.walk")!) { item in
            //trigger action only uf pin is visible
            if imageView.isHidden != true {
                //self.getDirection()
                self.test.run(isHidden: true)
            } else {
                //self.mapView.userTrackingMode = .follow
                self.test.run(isHidden: false)
            }
                }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
