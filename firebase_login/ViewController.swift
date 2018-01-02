//
//  ViewController.swift
//  firebase_login
//
//  Created by Qichen Huang on 2017-12-31.
//  Copyright © 2017 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogout))
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            //delay: to avoid presenting too many controllers at same time
        }
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()//cache out currentUser
        } catch let logoutError {
            print(logoutError)
        }
        
        present(LoginController(), animated: true, completion: nil)
    }

}

