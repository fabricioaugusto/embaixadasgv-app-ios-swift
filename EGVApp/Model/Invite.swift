//
//  Invite.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

struct Invite {
    let id: String
    let name_sender: String
    let email_sender: String
    let name_receiver: String
    let email_receiver: String
    let embassy_receiver: BasicEmbassy?
    let isLeader: Bool
    let isManager: Bool
    let invite_code: Int
    
    init?(dictionary: [String: Any]) {
        
        self.id = dictionary["id"] as! String
        self.name_sender = dictionary["name_sender"] as! String
        self.email_sender = dictionary["email_sender"] as! String
        self.name_receiver = dictionary["name_receiver"] as! String
        self.email_receiver = dictionary["email_receiver"] as! String
        self.embassy_receiver = BasicEmbassy(dictionary: dictionary["embassy_receiver"] as! [String : Any])!
        self.isLeader = dictionary["isLeader"] as? Bool ?? false
        self.isManager = dictionary["isManager"] as? Bool ?? false
        self.invite_code = dictionary["invite_code"] as? Int ?? 0
    }
}
