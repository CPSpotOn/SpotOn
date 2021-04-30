//
//  ProfileViewController.swift
//  SpotOn
//
//  Created by William Rai on 4/17/21.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        ageTextField.delegate = self
        bioTextField.delegate = self
        
        
        let query = PFQuery(className: "Profile")
        

        query.findObjectsInBackground { (userProfile, error) in
            if error == nil {
                if let savedData = userProfile {
                    for userProfile in savedData{
//                        self.profileImage.image = (userProfile["pic"]) as! UIImage
                        self.nameTextField.text = (userProfile["name"]) as? String
                        self.ageTextField.text = (userProfile["age"]) as? String
                        self.bioTextField.text = (userProfile["bio"]) as? String
                    }
                }
            }
        }

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func backToMap(_ sender: Any) {
        
        let profile = PFObject(className: "Profile")
        
        let imageData = profileImage.image!.pngData()
        let imageFile = PFFileObject(data: imageData!)
        
        profile["name"] = nameTextField.text!
        profile["age"] = ageTextField.text!
        profile["bio"] = bioTextField.text!
        profile["image"] = imageFile
        
        profile.saveInBackground { (success, error) in
            if success {
                print("Data Saved!")
            }
            else {
                print("Data didn't save :(")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        bioTextField.resignFirstResponder()
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }
        else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        profileImage.image = scaledImage

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

extension ProfileViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
