//
//  Embassy.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

struct Embassy {
    let id: String
    let name: String
    let city: String
    let neighborhood: String?
    let state: String
    let state_short: String
    let cover_img: String?
    let cover_img_file_name: String?
    let phone: String?
    let email: String?
    let status: String?
    let frequency: String?
    let members_quantity: Int
    let approved_by_id: String?
    let approved_by_name: String?
    let leader_id: String
    let leader_username: String
    let leader: BasicUser?
    let embassySponsor_id: String?
    let embassySponsor: EmbassySponsor?
    
    init?(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.neighborhood = dictionary["neighborhood"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.state_short = dictionary["state_short"] as? String ?? ""
        self.cover_img = dictionary["cover_img"] as? String
        self.cover_img_file_name = dictionary["cover_img_file_name"] as? String
        self.phone = dictionary["phone"] as? String
        self.email = dictionary["email"] as? String
        self.status = dictionary["status"] as? String
        self.frequency = dictionary["frequency"] as? String
        self.members_quantity = dictionary["members_quantity"] as? Int ?? 0
        self.approved_by_id = dictionary["approved_by_id"] as? String
        self.approved_by_name = dictionary["approved_by_name"] as? String
        self.leader_id = dictionary["leader_id"] as? String ?? ""
        self.leader_username = dictionary["leader_username"] as? String ?? ""
        self.leader = (dictionary["leader"] != nil) ? BasicUser(dictionary: dictionary["leader"] as! [String : Any]) : nil
        self.embassySponsor_id = dictionary["embassySponsor_id"] as? String
        self.embassySponsor = dictionary["embassySponsor"] as? EmbassySponsor
    }
}

struct BasicEmbassy {
    let id: String
    let name: String
    init?(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
    }
    
    func toBasicMap() -> [String: Any] {
        return ["id": id, "name": name]
    }
}
