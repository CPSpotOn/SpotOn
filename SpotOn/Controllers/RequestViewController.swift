//
//  AlertViewController.swift
//  SpotOn
//
//  Created by My Mac on 5/6/21.
//

import UIKit
import Parse

//copy this in your file
protocol GeneratedToHomeDelegate {
    //add parameters if needed
    func gotoHomeAndAction(access: String, createSession: Bool);
}

class RequestViewController: UIViewController {
    
    @IBOutlet weak var invitationLinkField: UITextField!
    
    @IBOutlet weak var generateLinkBtn: UIButton!
    @IBOutlet weak var codeLabel: UILabel!
    
    
    var generateToHomeDelegate : GeneratedToHomeDelegate!
    var accessKey : String?
    let viewColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        invitationLinkField.delegate = self
        
        //sets the background as transparent
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

    }
    
    @IBAction func onGenerate(_ sender: Any) {
        accessKey = randomString(length: 6)
        codeLabel.text = accessKey!
        generateToHomeDelegate.gotoHomeAndAction(access: accessKey!, createSession: true)
        
        //if you want to dismiss
        //dismiss(animated: true, completion: nil)
        codeLabel.text = accessKey
        
        print(randomString(length: 6))
        dismiss(animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
      let numbers = "0123456789"
      return String((0..<length).map{ _ in numbers.randomElement()! })
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- UITextFieldDelegate
extension RequestViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accessKey = textField.text!
        generateToHomeDelegate.gotoHomeAndAction(access: accessKey!, createSession: false)
        dismiss(animated: true, completion: nil)
        return true
    }
}
