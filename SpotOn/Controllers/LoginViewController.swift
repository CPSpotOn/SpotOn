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
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
    var currentGradient : Int = 0
    
    let gradientOne = UIColor(red: 44/255, green: 62/255, blue: 103/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(hexString: "#413c69")
        gradientChangeAnimation.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpGradientAnimation()
    }
    
    func setUpGradientAnimation() {
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        
        
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        self.view.layer.insertSublayer(gradient, at: 0)
        
        animateGradient()
    }
    
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        gradientChangeAnimation.duration = 2.5
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
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

extension LoginViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}
