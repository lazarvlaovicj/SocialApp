//
//  FeedVC.swift
//  devslopes-social
//
//  Created by PRO on 3/17/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var captionField: FancyField!
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    static var imageCache1: NSCache<NSString, UIImage> = NSCache()
    var isAdded: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts = [] // THIS IS THE NEW LINE
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(String(describing: snap.value))")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let postKey = snap.key
                        let post = Post(postKey: postKey, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts.reversed()[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                if let img1 = FeedVC.imageCache1.object(forKey: post.profileLink as NSString) {
                    cell.configCell(post: post, img: img, img1: img1)
                }
            } else {
                cell.configCell(post: post)
            }
            return cell
            
        }
        return UITableViewCell()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            isAdded = true
            picker.dismiss(animated: true, completion: nil)
            
        } else {
            print("Error with picking an image")
        }
    }
    
    @IBAction func addImagePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postedBtnTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let _ = captionField.text, captionField.text != "" else {
            print("You must enter the caption!")
            return
        }
        
        guard let img = addImage.image, isAdded == true else {
            print("You must chose the image!")
            return
        }
        
        let uid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            DataService.ds.REF_STORAGE_IMG.child(uid).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("Error with uploading an image to Firebase Storage")
                } else {
                    print("Successfully uploaded image to Firebase Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(url: url)
                        print("Posted to Firebase")
                    }
                }
            })
        }
    }
    
    func postToFirebase(url: String) {
        
        let _ = DataService.ds.REF_CURRENT_USER.child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.value as? String {
                let _ = DataService.ds.REF_CURRENT_USER.child("profileLink").observeSingleEvent(of: .value, with: { (FIRSnapshot) in
                    
                    if let snapshot1 = FIRSnapshot.value as? String {
                        let post: Dictionary<String, AnyObject> = [
                            "caption": self.captionField.text as AnyObject,
                            "imageUrl": url as AnyObject,
                            "likes": 0 as AnyObject,
                            "postedBy": snapshot as AnyObject,
                            "profileLink": snapshot1 as AnyObject
                        ]
                        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
                        firebasePost.setValue(post)
                        self.captionField.text = ""
                    }

                })
            }
        })
        
        addImage.image = UIImage(named: "add-image")
        isAdded = false
        
        tableView.reloadData()
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        
        let _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        print("Successfully signed out")
        performSegue(withIdentifier: "toSignInVC", sender: nil)
        
    }
    
}
