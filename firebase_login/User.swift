//
//  User.swift
//  firebase_login
//
//  Created by Qichen Huang on 2018-01-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Foundation

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?

    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}


