//
//  FeedsViewController.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/19/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var captionLabel: FancyTextField!
    @IBOutlet weak var addImageImageView: UIImageView!
    @IBOutlet weak var feedsTableView: UITableView!
    var imagePicker: UIImagePickerController!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    static var profileImageUrl: String?
    
    var imageSelected = false
    
    var posts = [Post]()
    var displayName = String()
    var userKey = String()
    
    static var settingsSaved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        feedsTableView.delegate = self
        feedsTableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? [String: Any] {
                        let key = snap.key
                        let post = Post(postId: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
                
                self.posts.sort(by: { (p1, p2) -> Bool in
                    return p1.postDate > p2.postDate
                })
                
                self.feedsTableView.reloadData()
            }
            
        })
        
        DataService.ds.REF_CURRENT_USER.observe(.value, with: { (snapshot) in
            if snapshot.hasChild("displayName") {
                if let dict = snapshot.value as? [String: Any] {
                    self.displayName = dict["displayName"]! as! String
                }
            }
        })
        
        userKey = DataService.ds.REF_CURRENT_USER.key
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if FeedsViewController.settingsSaved {
            for case let cell as PostCell in feedsTableView.visibleCells {
                cell.loadProfileImageForCell()
            }
        }
        
        FeedsViewController.settingsSaved = false
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            
             
            if let image = FeedsViewController.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, userKey: userKey, image: image)
                return cell
            }
            else {
                cell.configureCell(post: post, userKey: userKey )
                return cell
            }

        }
        else {
            return PostCell()
        }
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImageImageView.image = image
            imageSelected = true
        }
        else {
            print("HEcTOR: Valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        
        do {
            _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "showMain", sender: nil)
        }
        catch let error {
            print ("Sign out error: \(error)")
        }
    }
    
    
    @IBAction func addImageClicked(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func postButtonClicked(_ sender: Any) {
        guard let caption = captionLabel.text, caption != "" else {
            print("HECTOR: caption mus be entered")
            return
        }
        
        guard let img = addImageImageView.image, imageSelected == true else {
            print("HECTOR: image mst be selected")
            return
        }
        
        if let imageData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imageUID = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_POSTS_IMAGES.child(imageUID).put(imageData, metadata: metaData, completion: { (metaData, error) in
                if error != nil {
                    print ("HECTOR: Unable to upload to fb storage")
                }
                else {
                    print ("HECTOR: Successfully uploaded image to fb storage")
                    let downloadUrl = metaData?.downloadURL()?.absoluteString
                    self.postToFirebase(imageUrl: downloadUrl!)
                }
            })
        }
    }
    
    func postToFirebase(imageUrl: String) {
        
        let timeInterval: Double = NSDate().timeIntervalSince1970
        
        let post: [String: Any] = [
            "caption": captionLabel.text!,
            "imageUrl": imageUrl,
            "likes": 0,
            "displayName": displayName,
            "postDate" : timeInterval.description,
            "uid": userKey]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        
        DataService.ds.REF_CURRENT_USER.child("posts").child(firebasePost.key).setValue(true)
        
        
        captionLabel.text = ""
        imageSelected = false
        addImageImageView.image = UIImage(named: "add-image")
        
        feedsTableView.reloadData()
    }
    
    
    
}
