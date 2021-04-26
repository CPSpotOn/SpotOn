//
//  RegisterViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/17/21.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onRegister(_ sender: Any) {
       register()
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
