//
//  PostCell.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/20/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    
    func confirgureCell(post: Post, image: UIImage? = nil) {
        self.post = post
        self.likesLabel.text = "\(post.likes)"
        self.caption.text = post.caption
        
        if image != nil {
            self.postImg.image = image!
        }
        else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print ("HECTOR: error downlaing image from fB storage \(error)")
                }
                else {
                    print ("HECTOR: Image dl from FB Storage")
                    if data != nil {
                        if let image = UIImage(data: data!) {
                            self.postImg.image = image
                            FeedsViewController.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
    }
  

}
