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
        
        observeMessages()
    }
    
    var messages = [Message]()

    private func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                
                //DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                //})
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
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
        //You can use the observeSingleEventOfType method to simplify this scenario: the event callback added triggers once and then does not trigger again.
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                
                //
                self.navigationItem.titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
                self.navigationItem.titleView?.backgroundColor = .red
//            self.navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showChatController)))
            }
        }, withCancel: nil)

    }
    
    @objc public func showChatControllerFor(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
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

