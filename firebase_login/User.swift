//
//  User.swift
//  firebase_login
//
//  Created by Qichen Huang on 2018-01-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Foundation

class User: NSObject {
    var name: String?
    var email: String?
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
    }
}


