//
//  Event.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

struct Event {
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
    let moderator_1: BasicUser?
    let moderator_2: BasicUser?
    let embassy_id: String?
    let embassy: BasicEmbassy?
    
    init?(dictionary: [String: Any]) {
        
        guard let id = dictionary["id"] as? String else { return nil }
        guard let theme = dictionary["theme"] as? String else { return nil }
        guard let tag = dictionary["tag"] as? String else { return nil }
        guard let description = dictionary["description"] as? String else { return nil }
        
        self.id = id
        self.theme = theme
        self.tag = tag
        self.description = description
        self.date = dictionary["date"] as? Timestamp
        self.schedule = dictionary["schedule"] as? String
        self.place = dictionary["place"] as? String
        self.cover_img = dictionary["cover_img"] as? String
        self.cover_img_file_name = dictionary["cover_img_file_name"] as? String
        self.observation = dictionary["observation"] as? String
        self.city = dictionary["city"] as? String
        self.state = dictionary["state"] as? String
        self.state_short = dictionary["state_short"] as? String
        self.street = dictionary["street"] as? String
        self.street_number = dictionary["street_number"] as? String
        self.neighborhood = dictionary["neighborhood"] as? String
        self.country = dictionary["country"] as? String
        self.postal_code = dictionary["postal_code"] as? String
        self.address = dictionary["address"] as? String
        self.lat = dictionary["address"] as? Double
        self.long = dictionary["long"] as? Double
        self.moderator_1 = (dictionary["moderator_1"] == nil) ? BasicUser(dictionary: dictionary["moderator_1"] as! [String : Any]) : nil
        self.moderator_2 = (dictionary["moderator_2"] == nil) ? BasicUser(dictionary: dictionary["moderator_2"] as! [String : Any]) : nil
        self.embassy_id = dictionary["embassy_id"] as? String
        self.embassy = BasicEmbassy(dictionary: dictionary["embassy"] as! [String : Any])!
    }
}
