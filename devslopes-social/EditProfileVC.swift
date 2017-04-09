//
//  EditProfileVC.swift
//  devslopes-social
//
//  Created by PRO on 4/1/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImg: CircleView!
    var imagePicker: UIImagePickerController!
    var isAdded: Bool = false
    static let editedProfile = DataService.ds.REF_CURRENT_USER.child("isEdited")
    
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Succeeded")
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = image
            isAdded = true
            picker.dismiss(animated: true, completion: nil)
            
        } else {
            print("Error with picking an image")
        }
    }
    
    @IBAction func imageSelector(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        print("Tapped")
    }
    

    @IBAction func doneTapped(_ sender: Any) {
        
        guard let _ = usernameField.text, usernameField.text != "" else {
            print("You must enter the username!")
            return
        }
        
        guard let img = profileImg.image, isAdded == true else {
            print("You have to chose the image!")
            return
        }
        
        let uid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            DataService.ds.REF_STORAGE_PROFILE.child(uid).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("Error with uploading an image to Firebase Storage")
                } else {
                    print("Successfully uploaded image to Firebase Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        let linkPic = DataService.ds.REF_CURRENT_USER.child("profileLink")
                        linkPic.setValue(url)
                        print("Posted to Firebase")
                    }
                }
            })
        }
        
        let user: String = usernameField.text!
        let userPost = DataService.ds.REF_CURRENT_USER.child("username")
        userPost.setValue(user)
        
        performSegue(withIdentifier: "toFeedVC", sender: nil)
    }
}
