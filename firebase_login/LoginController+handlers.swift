//
//  LoginController+handlers.swift
//  firebase_login
//
//  Created by Qichen Huang on 2018-01-03.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleLoginOrRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            self.messagesController?.fetchUserData()
            //successfully logged in our user
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let uid = user?.uid else { return }

            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")//must have a name
            
            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl] as [String : AnyObject]
                        
                        self.registerUserIntoDatabaseWith(uid: uid, values: values)
                    }
                })
            }
            
        }
    }
    
    private func registerUserIntoDatabaseWith(uid: String, values: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)//path
        
        usersReference.updateChildValues(values) { (error, ref) in
            if let error = error {
                print(error)
                return
            }
            
            self.messagesController?.navigationItem.title = values["name"] as? String
            //Saved user successfully into Firebase db
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}






