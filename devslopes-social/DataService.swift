//
//  DataService.swift
//  devslopes-social
//
//  Created by PRO on 3/23/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()

    //DB Reference
    private var _REF_USER = DB_BASE.child("users")
    private var _REF_POSTS = DB_BASE.child("posts")
    
    //Storage Reference
    private var _REF_STORAGE_IMG = STORAGE_BASE.child("post-pics")
    private var _REF_STORAGE_PROFILE = STORAGE_BASE.child("profile-pics")
    
    var REF_USER: FIRDatabaseReference {
        return _REF_USER
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_STORAGE_IMG: FIRStorageReference {
        return _REF_STORAGE_IMG
    }
    
    var REF_STORAGE_PROFILE: FIRStorageReference {
        return _REF_STORAGE_PROFILE
    }
    
    var REF_CURRENT_USER: FIRDatabaseReference {
        let key = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USER.child(key!)
        return user
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USER.child(uid).updateChildValues(userData)
    }
    
}
