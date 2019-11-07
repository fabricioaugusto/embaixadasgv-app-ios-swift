//
//  Embassy.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

class Embassy: Codable {
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
    let leader: User?
    let embassySponsor_id: String?
    let embassySponsor: EmbassySponsor?
}
