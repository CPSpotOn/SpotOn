
//
//  SettingsViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/12/21.
//
import UIKit
import SwiftHEXColors

protocol ByeByeProtocol {
    func dismissFloatingPanel(isDismiss : Bool)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var unitsSC: UISegmentedControl!
    @IBOutlet weak var transportationSC: UISegmentedControl!
    
    var dismissProtocol : ByeByeProtocol!
    
    let userD = UserDefaults.standard
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        let transport = userD.string(forKey: "transport")
        let unit =  userD.string(forKey: "unit")
        
        if transport != nil {
            if transport! == "Car" {
                transportationSC.selectedSegmentIndex = 0
            } else {
                transportationSC.selectedSegmentIndex = 1
            }
        }
        if unit != nil {
            if unit! == "SI" {
                unitsSC.selectedSegmentIndex = 0
            } else {
                unitsSC.selectedSegmentIndex = 1
            }
        }
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let transport = transportationSC.titleForSegment(at: transportationSC.selectedSegmentIndex)
        let unit =  unitsSC.titleForSegment(at: unitsSC.selectedSegmentIndex)
        userD.setValue(transport, forKey: "transport")
        userD.setValue(unit, forKey: "unit")
        userD.setValue(true, forKey: "save")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        dismissProtocol.dismissFloatingPanel(isDismiss: true)
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
