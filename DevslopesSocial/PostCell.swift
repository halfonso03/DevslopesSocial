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
    @IBOutlet weak var likeImageView: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRecognized))
        tap.numberOfTapsRequired = 1
        likeImageView.addGestureRecognizer(tap)
        likeImageView.isUserInteractionEnabled = true
    }

    func configureCell(post: Post, userKey: String, image: UIImage? = nil) {
        
        self.post = post
        
        likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postId)

        self.likesLabel.text = "\(post.likes)"
        self.caption.text = post.caption
        self.userNameLabel.text = post.displayName
        
        loadProfileImageForCell()
        
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
        
       
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImageView.image = UIImage(named: "empty-heart")
            }
            else {
                self.likeImageView.image = UIImage(named: "filled-heart")
            }
        })
    }
  
    func tapRecognized(recognizer: UITapGestureRecognizer) {
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImageView.image = UIImage(named: "filled-heart")
                self.post.adjustLike(addLike: true)
                self.likesRef.setValue(true)
            }
            else {
                self.likeImageView.image = UIImage(named: "empty-heart")
                self.post.adjustLike(addLike: false)
                self.likesRef.removeValue()
            }
        })

    }
    
    func loadProfileImageForCell() {
        DataService.ds.REF_USERS.queryOrderedByKey().queryEqual(toValue: self.post.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                if let dict = snapshots.first?.value as? [String: Any] {
                    if let profileImageUrl = dict["profileImageUrl"] as? String {
                        
                        if let image = FeedsViewController.imageCache.object(forKey: profileImageUrl as NSString) {
                            self.profileImg.image = image
                        }
                        else {
                            let ref = FIRStorage.storage().reference(forURL: profileImageUrl)
                            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                                if error != nil {
                                    print ("HECTOR: error downloading profile image for post \(error)")
                                }
                                else {
                                    if data != nil {
                                        if let image = UIImage(data: data!) {
                                            self.profileImg.image = image
                                            FeedsViewController.imageCache.setObject(image, forKey: profileImageUrl as NSString)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
            
        })
    }
    
}
