//
//  User.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let id: String
    var name: String
    var email: String
    var status: String?
    var gender: String?
    var description: String?
    var birthdate: String?
    var occupation: String?
    var city: String?
    var state: String?
    var state_short: String?
    var profile_img: String?
    var profile_img_file_name: String?
    let verified: Bool
    var facebook: String?
    var twitter: String?
    var instagram: String?
    var linkedin: String?
    var whatsapp: String?
    var youtube: String?
    var behance: String?
    var github: String?
    var website: String?
    var last_device_os: String?
    var last_device_version: String?
    var last_app_update: String?
    var fcm_token: String?
    var register_number: Int
    var register_date: Timestamp?
    var topic_subscribed: Bool
    var leader: Bool
    var manager: Bool
    var sponsor: Bool
    var committee_leader: Bool
    var committee_manager: Bool
    var committee_member: Bool
    var committee: Committee?
    var username: String?
    var embassy_id: String?
    var embassy: BasicEmbassy
    
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
        self.register_date = dictionary["register_date"] as? Timestamp
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
    
    func toMap() -> [String:Any?]{
            return ["id": self.id,
                    "name": name,
                    "email": email,
                    "status": self.status,
                    "gender": gender,
                    "description": description,
                    "occupation": occupation,
                    "city": city,
                    "state": state,
                    "state_short": state_short,
                    "profile_img": profile_img,
                    "verified": verified,
                    "facebook": facebook,
                    "twitter": twitter,
                    "instagram": instagram,
                    "linkedin": linkedin,
                    "whatsapp": whatsapp,
                    "youtube": youtube,
                    "behance": behance,
                    "github": github,
                    "website": website,
                    "last_device_os": last_device_os,
                    "last_device_version": last_device_version,
                    "last_app_update": last_app_update,
                    "fcm_token": fcm_token,
                    "register_number": register_number,
                    "register_date": register_date,
                    "topic_subscribed": self.topic_subscribed,
                    "leader": self.leader,
                    "manager": self.manager,
                    "sponsor": self.sponsor,
                    "committee_leader": self.committee_leader,
                    "committee_manager": self.committee_manager,
                    "committee_member": self.committee_member,
                    "committee": self.committee,
                    "username": self.username,
                    "embassy_id": self.embassy_id,
                    "embassy": self.embassy]
        }
    
}

struct BasicUser {
    let id: String
    let name: String
    let profile_img: String?
    let embassy_id: String?
    let occupation: String?
    let username: String?
    let leader: Bool
    let manager: Bool
    let sponsor: Bool
    let committee_leader: Bool
    let verified: Bool
    
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String else { return nil }
        guard let name = dictionary["name"] as? String else { return nil }
        
        self.id = id
        self.name = name
        self.occupation = dictionary["occupation"] as? String
        self.profile_img = dictionary["profile_img"] as? String
        self.verified = dictionary["verified"] as? Bool ?? false
        self.leader = dictionary["leader"] as? Bool ?? false
        self.manager = dictionary["manager"] as? Bool ?? false
        self.sponsor = dictionary["sponsor"] as? Bool ?? false
        self.committee_leader = dictionary["committee_leader"] as? Bool ?? false
        self.username = dictionary["username"] as? String
        self.embassy_id = dictionary["embassy_id"] as? String
    }
    
}

