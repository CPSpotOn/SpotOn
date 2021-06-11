//
//  OptionsViewController.swift
//  SpotOn
//
//  Created by William on 6/6/21.
//

import UIKit
import FloatingPanel

protocol OptionTapProtocol {
    func onWhichTap(option : String)
}

class OptionsViewController: UIViewController , FloatingPanelControllerDelegate {

    ///container labels
    @IBOutlet weak var locationContainerView: UIView!
    @IBOutlet weak var connectContainerView: UIView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var goContainerView: UIView!
    @IBOutlet weak var accessCodeLabel: UILabel!
    
    ///location label which is set based on the current location of the user
    @IBOutlet weak var locationLabel: UILabel!
    
    
    // floating panels
    var connectPanel : FloatingPanelController!
    var optionTapDelegate : OptionTapProtocol!
    var generateTransferDelegate : GeneratedToHomeDelegate!
    var controller : HomeViewController!
    
    
    //View Controllers for sliding in View Controller
//    var profileVC : ProfileViewController!
//    var visualEffectView : UIVisualEffectView! //visual effect to blur the background when VC slides in
//    let cardSlidInHeight : CGFloat = 400
//    let cardHeight : CGFloat = 600
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makeCircleButton()
       
    }
    
    func makeCircleButton(){
        locationContainerView.layer.cornerRadius = 10
        connectContainerView.layer.cornerRadius = connectContainerView.frame.size.width / 2
        
        profileContainerView.layer.cornerRadius = profileContainerView.frame.size.width / 2
        
        pinContainerView.layer.cornerRadius = pinContainerView.frame.size.width / 2
        
        goContainerView.layer.cornerRadius = goContainerView.frame.size.width / 2
        
    }
    
    
    @IBAction func onConnect(_ sender: Any) {
        print("connect tapped")
//        connectPanel = FloatingPanelController()
//        connectPanel.delegate = self
//
//        let connectVC = self.storyboard?.instantiateViewController(identifier: "ConnectVC") as? ConnectViewController
//        connectVC?.dismissProtocl = self
//        connectVC?.generateToHomeDelegate = generateTransferDelegate
//
//
//        connectPanel.set(contentViewController: connectVC)
//
//        self.view.addSubview(connectPanel.view)
//
//        connectPanel.view.frame = self.view.bounds
//        connectPanel.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            connectPanel.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
//            connectPanel.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0),
//            connectPanel.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0),
//            connectPanel.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
//        ])
//
//        // Add the floating panel controller to the controller hierarchy.
//        self.addChild(connectPanel)
//
//        // Show the floating panel at the initial position defined in your `FloatingPanelLayout` object.
//
//        connectPanel.layout = OptionFloatingPanelLayout()
//        connectPanel.show(animated: true) {
//            // Inform the floating panel controller that the transition to the controller hierarchy has completed.
//            self.connectPanel.panGestureRecognizer.isEnabled = false
//            self.connectPanel.didMove(toParent: self)
//
//        }
//
//        connectPanel.addPanel(toParent: self)
//        print(connectPanel.state)
        
        //optionTapDelegate.onWhichTap(option: "connect")
        let alertVc = AlertService().alert(me: controller)
        alertVc.modalPresentationStyle = .overCurrentContext
        alertVc.providesPresentationContextTransitionStyle = true
        alertVc.definesPresentationContext = true
        alertVc.modalTransitionStyle = .crossDissolve
        alertVc.accessDelegate = self
        self.present(alertVc, animated: true, completion: nil)
    }
    
    //Profile
    
    @IBAction func onProfileTap(_ sender: Any) {
        print("profile")
        setUpProfleVC()
    }
    
    //make profileVC ready for sliding in
    func setUpProfleVC(){
//        visualEffectView = UIVisualEffectView()
//        visualEffectView.frame = self.view.frame
//
//        self.view.addSubview(visualEffectView)
//
//        profileVC = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as? ProfileViewController
//        self.addChild(profileVC)
//        self.view.addSubview(profileVC.view)
//
//        //cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleHeight, width: self.view.bounds.width, height: cardHeight)
//        profileVC.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: cardHeight)
//
//        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) {
//
//            //animations
//            self.profileVC.view.frame.origin.y = self.view.frame.height - self.cardSlidInHeight
//
//            print("animation")
//
//        } completion: { finished in
//
//        }
//
//
//
//        profileVC.view.clipsToBounds = true
        
        let profileVc = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as? ProfileViewController
        self.present(profileVc!, animated: true, completion: nil)

    }
    
 
    
    //onPinTap
    @IBAction func onPinTap(_ sender: Any) {
        print("Pin Tapped")
        optionTapDelegate.onWhichTap(option: "pin")
    }
    
    
    //on go tap
    @IBAction func onGoTap(_ sender: Any) {
        print("Go Tapped")
        optionTapDelegate.onWhichTap(option: "go")
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


extension OptionsViewController : ByeByeProtocol{
    func dismissFloatingPanel(isDismiss: Bool) {
        connectPanel.dismiss(animated: true, completion: nil)
    }
    
    //can change init state and height of the floating panel
    class OptionFloatingPanelLayout: FloatingPanelLayout {
        let position: FloatingPanelPosition = .bottom
        let initialState: FloatingPanelState = .full
        var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
                .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
            ]
        }
    }
}


//access protocol
extension OptionsViewController : AccessTransferProtocl{
    func passAccess(access: String) {
        print("access option VC: ", access)
        accessCodeLabel.alpha = 1.0
        accessCodeLabel.backgroundColor = .lightGray
        accessCodeLabel.layer.cornerRadius = 5
        accessCodeLabel.layer.masksToBounds = true
        accessCodeLabel.text = "Access Code : " + access
        
        let timeInterval = 10.0
        let left = CGAffineTransform(translationX: -(accessCodeLabel.frame.width), y: 0)

        print("x : ", accessCodeLabel.frame.origin.x)
        print("width : ", accessCodeLabel.frame.width)
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { Timer in
            DispatchQueue.main.async {
                UIView.animate(withDuration: timeInterval) {
                    //self.accessCodeLabel.transform = left
                    
                    self.accessCodeLabel.alpha = 0.0
                }
            }
        }
      
                //self.accessCodeLabel.isHidden = true
    }
}
