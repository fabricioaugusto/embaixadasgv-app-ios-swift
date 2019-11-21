//
//  Invite.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

struct Invite {
    var id: String
    var name_sender: String
    var email_sender: String
    var name_receiver: String
    var email_receiver: String
    var embassy_receiver: BasicEmbassy?
    var isLeader: Bool
    var isManager: Bool
    var invite_code: Int
    
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
