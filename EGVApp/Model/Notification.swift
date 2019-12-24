//
//  Notification.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class Notification {
    var id: String?
    let receiver_id: String
    let title: String
    let description: String
    let text: String
    let picture: String
    let type:  String
    var read: Bool
    let comment_id: String?
    let like_id: String?
    let relationship_id: String?
    let only_leaders: Bool
    let post_id: String?
    let company_id: String?
    let event_id: String?
    let sender_id: String?
    let created_at: Timestamp?
    
    init?(dictionary: [String: Any]) {
        
        guard let receiver_id = dictionary["receiver_id"] as? String else { return nil }
        guard let title = dictionary["title"] as? String else { return nil }
        guard let description = dictionary["description"] as? String else { return nil }
        guard let text = dictionary["text"] as? String else { return nil }
        guard let picture = dictionary["picture"] as? String else { return nil }
        guard let type = dictionary["type"] as? String else { return nil }
        
        self.id = dictionary["id"] as? String
        self.receiver_id = receiver_id
        self.title = title
        self.description = description
        self.text = text
        self.picture = picture
        self.type = type
        self.read = dictionary["read"] as? Bool ?? true
        self.comment_id = dictionary["comment_id"] as? String
        self.like_id = dictionary["like_id"] as? String
        self.relationship_id = dictionary["relationship_id"] as? String
        self.only_leaders = dictionary["only_leaders"] as? Bool ?? false
        self.post_id = dictionary["post_id"] as? String
        self.company_id = dictionary["company_id"] as? String
        self.event_id = dictionary["event_id"] as? String
        self.sender_id = dictionary["sender_id"] as? String
        self.created_at = dictionary["created_at"] as? Timestamp
    }
    
    func toMap() -> [String:Any?]{
        return ["id": self.id,
                "receiver_id": self.receiver_id,
                "title": self.title,
                "description": self.description,
                "text": self.text,
                "picture": self.picture,
                "type": self.type,
                "read": self.read,
                "comment_id": self.comment_id,
                "like_id": self.like_id,
                "relationship_id": self.relationship_id,
                "only_leaders": self.only_leaders,
                "post_id": self.post_id,
                "company_id": self.company_id,
                "event_id": self.event_id,
                "sender_id": self.sender_id,
                "created_at": self.created_at
        ]
    }
    
}
