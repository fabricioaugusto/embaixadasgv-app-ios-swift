//
//  Post.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    let id: String
    let type: String
    //let date: Timestamp?
    let schedule: String?
    let text: String?
    let picture: String?
    let picture_file_name: String?
    let title: String?
    let post_likes: Int
    let post_comments: Int
    let like_verified: Bool
    let liked: Bool
    let list_likes: [PostLike]?
    let user_id: String
    let user_verified: Bool
    let likes_ids: [String]?
    let embassy_id: String?
    let user: BasicUser
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String else { return nil }
        guard let type = dictionary["type"] as? String else { return nil }
        
        self.id = id
        self.type = type
        self.schedule = dictionary["schedule"] as? String
        self.text = dictionary["text"] as? String
        self.picture = dictionary["picture"] as? String
        self.picture_file_name = dictionary["picture_file_name"] as? String
        self.title = dictionary["title"] as? String
        self.post_likes = dictionary["post_likes"] as? Int ?? 0
        self.post_comments = dictionary["post_comments"] as? Int ?? 0
        self.like_verified = dictionary["like_verified"] as? Bool ?? false
        self.liked = dictionary["liked"] as? Bool ?? false
        self.list_likes = dictionary["list_likes"] as? [PostLike]
        self.user_id = dictionary["user_id"] as! String
        self.user_verified = dictionary["user_verified"] as? Bool ?? false
        self.likes_ids = dictionary["likes_ids"] as? [String]
        self.embassy_id = dictionary["embassy_id"] as? String
        self.user =  BasicUser(dictionary: dictionary["user"] as! [String : Any])!
    }
}
