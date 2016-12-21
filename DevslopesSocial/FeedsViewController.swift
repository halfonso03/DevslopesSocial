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

class FeedsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var feedsTableView: UITableView!

    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        feedsTableView.delegate = self
        feedsTableView.dataSource = self
     
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            cell.confirgureCell(post: post)
            return cell
        }
        else {
            return PostCell()
        }
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
}
