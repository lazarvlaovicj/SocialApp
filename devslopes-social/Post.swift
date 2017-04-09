//
//  Post.swift
//  devslopes-social
//
//  Created by PRO on 3/26/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _username: String!
    private var _profileLink: String!
    private var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var username: String {
        return _username
    }
    
    var profileLink: String {
        return _profileLink
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let username = postData["postedBy"] as? String {
            self._username = username
        }
        
        if let profileLink = postData["profileLink"] as? String {
            self._profileLink = profileLink
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey).child("likes")
    }
    
    func adjustLike(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.setValue(_likes)
    }
    
}












