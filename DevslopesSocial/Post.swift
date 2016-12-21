//
//  Post.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/20/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import Foundation

class Post {
    
    private var _caption: String!
    private var _likes: Int!
    private var _imageUrl: String!
    private var _postId: String!
    
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
    
    init(caption: String, likes: Int, imageUrl: String) {
       // self._postId = postId
        self._caption = caption
        self._likes = likes
        self._imageUrl = imageUrl
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
    }
    
}
