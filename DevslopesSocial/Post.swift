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
    
    var caption: String {
        return _caption ?? ""
    }
    
    var likes: Int {
        return _likes ?? 0
    }
    
    
    
    
}
