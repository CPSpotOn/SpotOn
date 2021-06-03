//
//  ProfileViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/17/21.
//
import UIKit
import SwiftHEXColors
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(hexString: "#709fb0")
        // Do any additional setup after loading the view.
        
        profImageView.layer.masksToBounds = true
        profImageView.layer.cornerRadius = 10.0
        
        usernameLabel.text = PFUser.current()?.username
        emailLabel.text = PFUser.current()?.email
        
        
        //getImage()
    }
    
    func getImage(){
        let query = PFQuery(className: "userImage")
        query.whereKey("username", equalTo: PFUser.current()?.username!)
        query.getFirstObjectInBackground { object, error in
            if object != nil{
                DispatchQueue.main.async {
                    //image
                    let imageFile = object!["image"] as! PFFileObject
                    let imageUrl = imageFile.url!
                    let url = URL(string: imageUrl)!
                    
                    self.profImageView.af.setImage(withURL: url)
                }
            }else{
                print("error retrieving image : \(error?.localizedDescription)")
                self.profImageView.image = UIImage(named: "user")

            }
        }
    }
    
    @IBAction func onChangePassword(_ sender: Any) {
        let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your new Password"
           
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("changed password ")
            if let name = alert.textFields?.first?.text {
                
                let query = PFUser.query()
                
                if let currUserName = PFUser.current()?.username {
                    query!.whereKey("username", equalTo: currUserName)
                }
        
                query!.getFirstObjectInBackground { object, error in
                    if error == nil{
                        object!["password"] = name
                        object!.saveInBackground()
                        print("password changed successfully")
                    }else{
                        print("error changing : \(error?.localizedDescription)")
                    }
                }
            }
         
        }))
        
        self.present(alert, animated: true)
    }
    
    
    
    //Opens Camera if there is in the system
    //otherwise opens photo gallery
    @IBAction func onTapImage(_ sender: Any) {
        print("test")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
       
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    
    
    //After picking a image
    //resize and show it in imageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 150, height: 150)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        profImageView.image = scaledImage
        dismiss(animated: true){
            let userImage = PFObject(className: "userImage")
            userImage["author"] = PFUser.current()
            userImage["username"] = PFUser.current()?.username
            
            let imageData = self.profImageView.image!.pngData()
            let file = PFFileObject(data: imageData!)
            userImage["image"] = file
            
            userImage.saveInBackground { success, error in
                if success{
                    print("sucessfully saved")
                }else{
                    print("error saving image : \(error?.localizedDescription)")
                }
            }
        }
        
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
