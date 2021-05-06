//
//  AlertViewController.swift
//  SpotOn
//
//  Created by My Mac on 5/6/21.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet weak var invitationLinkField: UITextField!
    
    @IBOutlet weak var generateLinkBtn: UIButton!
    @IBOutlet weak var codeLabel: UILabel!
    
    
    let viewColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets the background as transparent
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

    }
    
    @IBAction func onGenerate(_ sender: Any) {
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
