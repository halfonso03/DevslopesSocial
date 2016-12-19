//
//  ViewController.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/18/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SwiftKeychainWrapper


class SignInViewController: UIViewController {

    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if KeychainWrapper.standard.string(forKey: KEY_UID) != nil {
            performSegue(withIdentifier: "showFeeds", sender: nil)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if KeychainWrapper.standard.string(forKey: KEY_UID) != nil {
            performSegue(withIdentifier: "showFeeds", sender: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func faceBookButtonPressed(_ sender: UIButton) {
        
        let faceBookLogin = FBSDKLoginManager()
        
        faceBookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print ("HECTOR: Error authenticating with facebook \(error)")
            } else if (result?.isCancelled)! {
                print ("HECTOR: user canlled fb auth")
            } else {
                print ("HECTOR: Authed with fb")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if let email = emailAddressTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print ("HECTOR: Authed with firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                }
                else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if (error != nil) {
                            print ("HECTOR: Unable to auth with Firebase")
                        }
                        else {
                            print ("HECTOR: Authed with firebase")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    })
                }
            })
        }
    }
    
    
    func firebaseAuth(_ credential: FIRAuthCredential ) {
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if error != nil {
                print ("HECTOR: unable to auth with firebase")
            }
            else {
                print ("HECTOR: Authed with Firebase")
                if let u = user {
                    self.completeSignIn(id: u.uid)
                }
            }
        }
    }
    
    func completeSignIn(id: String) {
        let result = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print ("Hector : keychain saved result \(result)")
        performSegue(withIdentifier: "showFeeds", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

