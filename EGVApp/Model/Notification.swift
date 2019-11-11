//
//  Notification.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

struct Notification {
    let id: String
    let receiver_id: String
    let title: String
    let description: String
    let text: String
    let picture: String
    let type:  String
    let read: Bool
    let comment_id: String?
    let like_id: String?
    let relationship_id: String?
    let only_leaders: Bool
    let post_id: String?
    let company_id: String?
    let event_id: String?
    let sender_id: String?
    //let created_at: Timestamp?
}
