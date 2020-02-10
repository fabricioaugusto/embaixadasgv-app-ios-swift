//
//  PostComment.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class PostComment {
    let id: String
    let post_id: String
    let user_id: String
    let text: String
    let date: Timestamp?
    let user: BasicUser
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String else { return nil }
        
        self.id = id
        self.post_id = dictionary["post_id"] as! String
        self.user_id = dictionary["user_id"] as! String
        self.text = dictionary["text"] as! String
        self.date = dictionary["date"] as? Timestamp
        self.user =  BasicUser(dictionary: dictionary["user"] as! [String : Any])!
    }
}
