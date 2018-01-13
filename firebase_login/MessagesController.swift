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
    
    var messages = [Message]()

    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            //user.setValuesForKeys(dictionary)
            self.showChatControllerFor(user: user)
            
        }, withCancel: nil)
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
            }
            
            self.messages.removeAll()
            self.messagesDictionary.removeAll()
            self.tableView.reloadData()
            
            self.observeUserMessages()
            
        }, withCancel: nil)

    }
    
    var messagesDictionary = [String: Message]()
    
    private func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in //smart snapshot
           
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            
                            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                        })
                    }
                    
                    //DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    //})
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    public func showChatControllerFor(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
}

