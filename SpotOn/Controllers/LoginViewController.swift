//
//  LoginViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/11/21.
//

import UIKit
import Parse
import SwiftHEXColors

class LoginViewController: UIViewController {
    
    //MARK:- Variables
    //TODO: Connect all the outlets
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    //TODO: Add any required variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#413c69")
    }
    
    //MARK: - Action Outlets
    //TODO: Add a button action function for login
    
    @IBAction func onLoginPressed(_ sender: Any) {
        signIn()
        
    }

    //TODO: Add a button action function for register    
    @IBAction func onSignUpPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginToRegister", sender: nil)
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

extension LoginViewController{
   
    //MARK: - helper functions
    func signIn(){
        
        let userName = userNameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: userName, password: password) { (user, error) in
            if user != nil{
                self.userNameField.text = ""
                self.passwordField.text = ""
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
            }else{
                print("error \(error!.localizedDescription)")
                self.displayAlertWindow(error: error!.localizedDescription)
            }
        }
    }
    
    //alert window
    func displayAlertWindow(error : String){
        let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
