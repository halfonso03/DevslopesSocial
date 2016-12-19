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
class FeedsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        
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
