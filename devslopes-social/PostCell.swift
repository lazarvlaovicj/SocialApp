//
//  PostCell.swift
//  devslopes-social
//
//  Created by PRO on 3/19/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var REF_LIKES: FIRDatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didLiked))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configCell(post: Post, img: UIImage? = nil, img1: UIImage? = nil) {
        self.post = post
        REF_LIKES = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
        self.caption.text = post.caption
        self.likes.text = "\(post.likes)"
        self.usernameLbl.text = post.username
              
        if img != nil {
            self.postImg.image = img
        } else {
            
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    print("Error with downloading image from Firebase Storage")
                } else {
                    print("Successfully downloaded image from Firebase Storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        if img1 != nil {
            self.profileImg.image = img1
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.profileLink)
            ref.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    print("Error with downloading image from Firebase Storage")
                } else {
                    print("Successfully downloaded image from Firebase Storage")
                    if let imgData = data {
                        if let img1 = UIImage(data: imgData) {
                            self.profileImg.image = img1
                            FeedVC.imageCache1.setObject(img1, forKey: post.profileLink as NSString)
                        }
                    }
                }
                
            })
        }
        
        REF_LIKES.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
            
        })
    
    }
        
    func didLiked(sender: UITapGestureRecognizer) {
        REF_LIKES.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLike(addLike: true)
                self.REF_LIKES.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLike(addLike: false)
                self.REF_LIKES.removeValue()
            }
            
            })
        }

}
