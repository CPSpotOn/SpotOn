//
//  ConnectViewController.swift
//  SpotOn
//
//  Created by William on 6/7/21.
//

import UIKit

class ConnectViewController: UIViewController {

    @IBOutlet weak var invitationInputTextField: UITextField!
    @IBOutlet weak var codeLabel: UILabel!
    
    //variable
    var dismissProtocl : ByeByeProtocol!
    var accessKey : String?
    var generateToHomeDelegate : GeneratedToHomeDelegate!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        invitationInputTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onGenerateLink(_ sender: Any) {
        accessKey = randomString(length: 6)
        codeLabel.text = accessKey! + " : Give this access key to your friend"
        generateToHomeDelegate.gotoHomeAndAction(access: accessKey!, createSession: true)
    }
    
    //generate random access code
    func randomString(length: Int) -> String {
      let letters = "0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    @IBAction func onDismissPanel(_ sender: Any) {
        dismissProtocl.dismissFloatingPanel(isDismiss: true)
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

extension ConnectViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accessKey = textField.text!
        generateToHomeDelegate.gotoHomeAndAction(access: accessKey!, createSession: false)
       // dismiss(animated: true, completion: nil)
        return true
    }
}
