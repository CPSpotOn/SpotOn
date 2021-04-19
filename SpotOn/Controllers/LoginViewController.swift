//
//  LoginViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/11/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    //MARK:- Variables
    //TODO: Connect all the outlets
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    //TODO: Add any required variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Action Outlets
    //TODO: Add a button action function for login
    
    @IBAction func onLoginPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginToHome", sender: nil)
    }
    
    
    //TODO: Add a button action function for register
    
    @IBAction func onSignUpPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginToRegister", sender: nil)
    }
    
    
    //MARK: - helper functions
    func signIn(){
        /*
        let userName = userNameTF.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: userName, password: password) { (user, error) in
            if user != nil{
                self.userNameTF.text = ""
                self.passwordField.text = ""
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
            }else{
                print("error \(error!.localizedDescription)")
            }
        }*/
    }
    
    func register(){
        //when directly signing up from the same login Screen
        /*
        let user = PFUser()
        user.name = nameField.text
        user.username = userNameTF.text
        user.email = emailField.text
        user.password = passwordField.text
         
        user.signUpInBackground { (success, error) in
            if let error = error{
                print("error \(error.localizedDescription)")
            }else{ success
                self.userNameTF.text = ""
                self.nameField.text = ""
                self.emailField.text = ""
                self.passwordField.text = ""
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
            }
            
        }
        */
        
        //if registration is done in another screen
            //self.performSegue(withIdentifier: "loginToRegister", sender: nil)
        
        //or if google or facebook info is used
            //somewhere in the web
    }
    //end of helper functions

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
