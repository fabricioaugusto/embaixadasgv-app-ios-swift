//
//  Enrollment.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

struct Enrollment {
    var id: String
    let event_id: String
    let user_id: String
    //let event_date: Timestamp?
    let event: BasicEvent
    let waiting_list: Bool
    let user: BasicUser
    
    init?(dictionary: [String: Any]) {
        
        self.id = dictionary["id"] as? String ?? ""
        self.event_id = dictionary["event_id"] as! String
        self.user_id = dictionary["user_id"] as! String
        self.event = BasicEvent(dictionary: dictionary["event"] as! [String: Any])!
        self.waiting_list = dictionary["waiting_list"] as? Bool ?? false
        self.user = BasicUser(dictionary: dictionary["user"] as! [String : Any])!
    }
    
}
