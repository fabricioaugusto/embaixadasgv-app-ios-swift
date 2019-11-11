//
//  PostLike.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

struct PostLike {
    let id: String
    let post_id: String
    let user_id: String
    let user: User
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String else { return nil }
        guard let post_id = dictionary["post_id"] as? String else { return nil }
        guard let user_id = dictionary["user_id"] as? String else { return nil }
        guard let user = dictionary["user"] as? User else { return nil }
        
        self.id = id
        self.post_id = post_id
        self.user_id = user_id
        self.user = user
    }
}


