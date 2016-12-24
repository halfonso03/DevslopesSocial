//
//  Post.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/20/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _likes: Int!
    private var _imageUrl: String!
    private var _postId: String!
    private var _displayName: String!
    private var _postRef:  FIRDatabaseReference!
    private var _uid: String!
    private var _postDate: Double!
    
    var postId: String {
        return _postId ?? ""
    }
    
    var caption: String {
        return _caption ?? ""
    }
    
    var likes: Int {
        return _likes ?? 0
    }
    
    var imageUrl: String {
        return _imageUrl ?? ""
    }
    
    var displayName: String {
        return _displayName ?? ""
    }
    
    var uid: String {
        return _uid ?? ""
    }
    var postDate: Double {
        return _postDate
    }
    
    init(displayName: String, caption: String, likes: Int, imageUrl: String) {
       // self._postId = postId
        self._caption = caption
        self._likes = likes
        self._imageUrl = imageUrl
        self._displayName = displayName
    }
    
    init(postId: String, postData: [String: Any]) {
        self._postId = postId
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let displayName = postData["displayName"] as? String {
            self._displayName = displayName
        }
        
        self._uid = postData["uid"] as! String
        
        self._postDate = Double((postData["postDate"] as! String))!
        
        _postRef = DataService.ds.REF_POSTS.child(_postId)
    }
    
    func adjustLike(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        }
        else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    
}
