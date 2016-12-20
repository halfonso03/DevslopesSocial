//
//  DataService.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/20/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import Foundation
import Firebase


let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    public static let ds = DataService()
    private var _REF_DATABASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference {
        return DB_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }

    func createFirDatabaseUer(uid: String, userData: [String: String]) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
