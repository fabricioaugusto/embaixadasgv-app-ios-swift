//
//  Moderator.swift
//  EGVApp
//
//  Created by Fabricio on 14/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

class Moderator {
    var id: String?
    let name: String
    let profile_img: String?
    let description: String?
    let embassy_id: String?
    let occupation: String?
    let username: String?
    let user_id: String?
    
    init?(dictionary: [String: Any]) {
        
        guard let name = dictionary["name"] as? String else { return nil }
        
        self.id = dictionary["occupation"] as? String
        self.name = name
        self.occupation = dictionary["occupation"] as? String
        self.profile_img = dictionary["profile_img"] as? String
        self.description = dictionary["description"] as? String
        self.username = dictionary["username"] as? String
        self.embassy_id = dictionary["embassy_id"] as? String
        self.user_id = dictionary["embassy_id"] as? String
        
    }
    
    func toMap() -> [String:Any?]{
        return ["id": self.id,
                "name": self.name,
                "occupation": self.occupation,
                "description": self.description,
                "profile_img": self.profile_img,
                "username": self.username,
                "embassy_id": self.embassy_id,
                "user_id": self.user_id,
        ]
    }
    
}

