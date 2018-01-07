//
//  ViewController.swift
//  firebase_login
//
//  Created by Qichen Huang on 2017-12-31.
//  Copyright © 2017 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
     
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            //delay: to avoid presenting too many controllers at same time
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    public func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let key = Database.database().reference().child("users").child(uid)
        key.observeSingleEvent(of: .value, with: { (snapshot) in
        //observeSingleEvent - this block will be invoked and removed right away.
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
            }
        }, withCancel: nil)

    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()//cache out currentUser
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }

}

