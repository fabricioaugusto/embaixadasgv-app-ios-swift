//
//  InvitationRequest.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

class InvitationRequest {
    var id: String?
    let leaderId: String
    let leaderName: String
    let requestorEmail: String
    let requestorName: String
    let requestorWhatsapp: String
    let embassy: BasicEmbassy?
    
    init?(dictionary: [String: Any]) {
        
        guard let leaderId = dictionary["leaderId"] as? String else { return nil }
        guard let leaderName = dictionary["leaderName"] as? String else { return nil }
        guard let requestorEmail = dictionary["requestorEmail"] as? String else { return nil }
        guard let requestorName = dictionary["requestorName"] as? String else { return nil }
        guard let requestorWhatsapp = dictionary["requestorWhatsapp"] as? String else { return nil }
        
        self.id = dictionary["id"] as? String
        self.leaderId = leaderId
        self.leaderName = leaderName
        self.requestorEmail = requestorEmail
        self.requestorName = requestorName
        self.requestorWhatsapp = requestorWhatsapp
        self.embassy = (dictionary["embassy"] != nil) ? BasicEmbassy(dictionary: dictionary["embassy"] as! [String : Any]) : nil
    }
    
    func toMap() -> [String:Any?]{
        return ["id": self.id,
                "leaderId": self.leaderId,
                "leaderName": self.leaderName,
                "requestorEmail": self.requestorEmail,
                "requestorName": self.requestorName,
                "requestorWhatsapp": self.requestorWhatsapp,
                "embassy": self.embassy?.toBasicMap()
        ]
    }
}
