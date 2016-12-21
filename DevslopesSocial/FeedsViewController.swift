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

    @IBOutlet weak var addImageImageView: UIImageView!
    @IBOutlet weak var feedsTableView: UITableView!
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        feedsTableView.delegate = self
        feedsTableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? [String: Any] {
                        let key = snap.key
                        let post = Post(postId: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
                self.feedsTableView.reloadData()
            }
            
        })
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
                cell.confirgureCell(post: post, image: image)
                return cell
            }
            else {
                cell.confirgureCell(post: post)
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
        catch let error as Error {
            print ("Sign out error: \(error)")
        }
    }
    
    
    @IBAction func addImageClicked(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}
