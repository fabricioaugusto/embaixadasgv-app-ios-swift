//
//  User.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

struct User {
    let id: String
    let name: String
    let email: String
    let status: String?
    let gender: String?
    let description: String?
    let birthdate: String?
    let occupation: String?
    let city: String?
    let state: String?
    let state_short: String?
    let profile_img: String?
    let profile_img_file_name: String?
    let verified: Bool
    let facebook: String?
    let twitter: String?
    let instagram: String?
    let linkedin: String?
    let whatsapp: String?
    let youtube: String?
    let behance: String?
    let github: String?
    let website: String?
    let last_device_os: String?
    let last_device_version: String?
    let last_app_update: String?
    let fcm_token: String?
    let register_number: Int?
    let topic_subscribed: Bool
    let leader: Bool
    let manager: Bool
    let sponsor: Bool
    let committee_leader: Bool
    let committee_manager: Bool
    let committee_member: Bool
    let committee: Committee?
    let username: String?
    let embassy_id: String?
    let embassy: BasicEmbassy
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String else { return nil }
        guard let name = dictionary["name"] as? String else { return nil }
        guard let email = dictionary["email"] as? String else { return nil }
        
        self.id = id
        self.name = name
        self.email = email
        self.status = dictionary["status"] as? String
        self.gender = dictionary["gender"] as? String
        self.description = dictionary["description"] as? String
        self.birthdate = dictionary["birthdate"] as? String
        self.occupation = dictionary["occupation"] as? String
        self.city = dictionary["city"] as? String
        self.state = dictionary["state"] as? String
        self.state_short = dictionary["state_short"] as? String
        self.profile_img = dictionary["profile_img"] as? String
        self.profile_img_file_name = dictionary["profile_img_file_name"] as? String
        self.verified = dictionary["verified"] as? Bool ?? false
        self.facebook = dictionary["facebook"] as? String
        self.twitter = dictionary["twitter"] as? String
        self.instagram = dictionary["instagram"] as? String
        self.linkedin = dictionary["linkedin"] as? String
        self.whatsapp = dictionary["whatsapp"] as? String
        self.youtube = dictionary["youtube"] as? String
        self.behance = dictionary["behance"] as? String
        self.github = dictionary["github"] as? String
        self.website = dictionary["website"] as? String
        self.last_device_os = dictionary["last_device_os"] as? String
        self.last_device_version = dictionary["last_device_version"] as? String
        self.last_app_update = dictionary["last_app_update"] as? String
        self.fcm_token = dictionary["fcm_token"] as? String
        self.register_number = dictionary["register_number"] as? Int ?? 0
        self.topic_subscribed = dictionary["topic_subscribed"] as? Bool ?? false
        self.leader = dictionary["leader"] as? Bool ?? false
        self.manager = dictionary["manager"] as? Bool ?? false
        self.sponsor = dictionary["sponsor"] as? Bool ?? false
        self.committee_leader = dictionary["committee_leader"] as? Bool ?? false
        self.committee_manager = dictionary["committee_manager"] as? Bool ?? false
        self.committee_member = dictionary["committee_member"] as? Bool ?? false
        self.committee = dictionary["committee"] as? Committee
        self.username = dictionary["username"] as? String
        self.embassy_id = dictionary["embassy_id"] as? String
        self.embassy = BasicEmbassy(dictionary: dictionary["embassy"] as! [String : Any])!
    }
    
}
