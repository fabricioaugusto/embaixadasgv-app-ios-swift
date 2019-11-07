//
//  Event.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class Event: Codable {
    let id: String
    let theme: String
    let tag: String
    let description: String
    let date: Timestamp?
    let schedule: String?
    let place: String?
    let cover_img: String?
    let cover_img_file_name: String?
    let observation: String?
    let street: String?
    let street_number: String?
    let neighborhood: String?
    let city: String?
    let state: String?
    let state_short: String?
    let country: String?
    let postal_code: String?
    let address: String?
    let lat: Double?
    let long: Double?
    let moderator_1: User?
    let moderator_2: User?
    let embassy_id: String?
    let embassy: Embassy?
}
