//
//  User.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

class User: Codable {
    var id: String
    var name: String
    var email: String
    var status: String?
    var gender: String?
    var description: String?
    var birthdate: String?
    var occupation: String?
    var password: String?
    var city: String?
    var state: String?
    var state_short: String?
    var profile_img: String?
    var profile_img_file_name: String?
    var verified: Bool
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
    var embassy: Embassy
}
