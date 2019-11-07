//
//  PostLike.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

class PostLike: Codable {
    var id: String
    var post_id: String
    var user_id: String
    var user: User
}
