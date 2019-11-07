//
//  Post.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class Post: Codable {
    var id: String
    var type: String
    var date: Timestamp?
    var schedule: String?
    var text: String?
    var picture: String?
    var picture_file_name: String?
    var title: String?
    var post_likes: Int
    var post_comments: Int
    var like_verified: Bool
    var liked: Bool
    var list_likes: [PostLike]?
    var user_id: String
    var user_verified: Bool
    var likes_ids: [String]?
    var embassy_id: String?
    var user: User
}
