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

protocol AccessTransferProtocl {
    func passAccess(access : String)
}

class RequestViewController: UIViewController {
    
    @IBOutlet weak var invitationLinkField: UITextField!
    
    @IBOutlet weak var generateLinkBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    
    var generateToHomeDelegate : GeneratedToHomeDelegate!
    var accessDelegate : AccessTransferProtocl!
    var accessKey : String?
    let viewColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        invitationLinkField.delegate = self
        
        //sets the background as transparent
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        containerView.layer.cornerRadius = 10
        generateLinkBtn.layer.cornerRadius = 5

    }
    
    @IBAction func onGenerate(_ sender: Any) {
//        let request_list = PFObject(className: "request_list")
//        let rString = randomString(length: 12)
//        request_list["userId"] = PFUser.current()
//        request_list["token"] = rString
//
//        request_list.saveInBackground { (success, error) in
//            if success{
//                print("saved")
//                DispatchQueue.main.async {
//                    self.codeLabel.text = rString
//                }
//            }else{
//                print("error : \(error?.localizedDescription)")
//            }
//        }
        accessKey = randomString(length: 6)
        //codeLabel.text = accessKey!
        generateToHomeDelegate.gotoHomeAndAction(access: accessKey!, createSession: true)
        accessDelegate.passAccess(access: accessKey!)
        //if you want to dismiss
        //dismiss(animated: true, completion: nil)
        //codeLabel.text = accessKey
        
        print(randomString(length: 6))
        dismiss(animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
      let letters = "0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

extension RequestViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accessKey = textField.text!
        generateToHomeDelegate.gotoHomeAndAction(access: accessKey!, createSession: false)
        dismiss(animated: true, completion: nil)
        return true
    }
}
