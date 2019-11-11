//
//  PostComment.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

struct PostComment {
    let id: String
    let post_id: String
    let user_id: String
    let text: String
    //let date: Timestamp?
    let user: User
}
