//
//  PostComment.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class PostComment: Codable {
    var id: String
    var post_id: String
    var user_id: String
    var text: String
    var date: Timestamp?
    var user: User
}
