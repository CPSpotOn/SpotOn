//
//  RegisterViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/17/21.
//

import UIKit
import Parse
import SwiftHEXColors
class RegisterViewController: UIViewController {

    //outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var regBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editPlaceHolder(view: nameField, placeholder: "Name", color: UIColor.black)
        editPlaceHolder(view: emailField, placeholder: "Email", color: UIColor.black)
        editPlaceHolder(view: usernameField, placeholder: "Username", color: UIColor.black)
        editPlaceHolder(view: passwordField, placeholder: "Password", color: UIColor.black)
        
        regBtn.layer.cornerRadius = 12
        view.backgroundColor = UIColor(hexString: "#4a47a3")
        
    }
    

    @IBAction func onRegister(_ sender: Any) {
       register()
    }
    
    func editPlaceHolder(view : UITextField, placeholder : String, color : UIColor){
        view.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : color])
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

extension RegisterViewController{
    func register(){
        //when directly signing up from the same login Screen
        
        let user = PFUser()
        user["name"] = nameField.text
        user.email = emailField.text
        user.username = usernameField.text
        user.password = passwordField.text
         
        user.signUpInBackground { (success, error) in
            if let error = error{
                print("error \(error.localizedDescription)")
                self.displayAlertWindow(error : error.localizedDescription)
            }else{
                //success
                self.usernameField.text = ""
                self.nameField.text = ""
                self.emailField.text = ""
                self.passwordField.text = ""
                self.performSegue(withIdentifier: "loginToHome", sender: nil)
                //"loginToHome" is an identifier set in the segue arrow in storyboard between RegisterViewController and HomeViewController
            }
            
        }
        
        
        //if registration is done in another screen
            //self.performSegue(withIdentifier: "loginToRegister", sender: nil)
        
        //or if google or facebook info is used
            //somewhere in the web
    }
    
    //alert window
    func displayAlertWindow(error : String){
        let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    //end of helper functions
}
