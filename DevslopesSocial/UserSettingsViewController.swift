//
//  UserSettingsViewController.swift
//  DevslopesSocial
//
//  Created by Alfonso, Hector I. on 12/22/16.
//  Copyright © 2016 Alfonso, Hector I. All rights reserved.
//

import UIKit
import Firebase

class UserSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var displayNameTextField: FancyTextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    private var imageSelected = false
    var requiresDisplayName = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        if !requiresDisplayName {
            showDisplayName()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if requiresDisplayName {
            showAlert(title: "Settings", message: "Your display name is required to post. Please enter a display name and choose a profile picture.", actionTitle: "OK", actionStyle: .default)
            
            requiresDisplayName = false
        }
    }
    
    @IBAction func profileImageClicked(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func saveSettingClicked(_ sender: Any) {
        
        guard let displayNameEntered = displayNameTextField.text, displayNameEntered != "" else {
            print("HECTOR: caption mus be entered")
            return
        }
        
        
        
        DataService.ds.REF_USERS.queryOrdered(byChild: "displayName").queryEqual(toValue: displayNameEntered).observeSingleEvent(of: .value, with: {(snapshot) in
            
            var canUseDisplayName = true
            
            if let snap = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in snap {
                    if child.key != DataService.ds.REF_CURRENT_USER.key {
                        canUseDisplayName = false
                        self.showAlert(title: "Settings", message: "The display name entered is already taken by another user. Please choose another.", actionTitle: "OK", actionStyle: .cancel)

                    }
                }
            }
            
            if canUseDisplayName {
                
                DataService.ds.REF_CURRENT_USER.child("displayName").setValue(displayNameEntered)

                guard let img = self.profileImageView.image, self.imageSelected == true else {
                    self.showAlert(title: "Settings", message: "Your settings have been updated. A default image will display for your profile. You may choose a profile image at a later time.", actionTitle: "OK", actionStyle: .default)
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
                            DataService.ds.REF_CURRENT_USER.child("profileImageUrl").setValue(downloadUrl)
                            self.imageSelected = false
                            self.showAlert(title: "Settings", message: "Your settings have been updated.", actionTitle: "OK", actionStyle: .default)
                            FeedsViewController.settingsSaved = true
                        }
                    })
                }
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            imageSelected = true
        }
        else {
            print("HECTOR: Valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

   
    @IBAction func backButtonClicked(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showFeeds", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFeeds" {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func showDisplayName() {
        DataService.ds.REF_CURRENT_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("displayName") {
                self.displayNameTextField.text = ((snapshot.value as? [String: Any])?["displayName"] as! String)
            }
            
            if snapshot.hasChild("profileImageUrl") {
                let url = (snapshot.value as? [String: Any])?["profileImageUrl"] as! String
                let ref = FIRStorage.storage().reference(forURL: url)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print ("HECTOR: error downlaing image from fB storage \(error)")
                    }
                    else {
                        print ("HECTOR: Image dl from FB Storage")
                        if data != nil {
                            if let image = UIImage(data: data!) {
                                self.profileImageView.image = image
                                self.imageSelected = true
                            }
                        }
                    }
                })
            }
            
            
        }, withCancel: nil)
    }
    
    func showAlert(title: String, message: String, actionTitle: String,  actionStyle: UIAlertActionStyle) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}
