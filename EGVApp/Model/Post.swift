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
    let user: User
}
