//
//  EmbassyPhoto.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

struct EmbassyPhoto {
    let id: String
    //let date: Timestamp?
    let text: String?
    let picture: String
    let picture_file_name: String?
    let thumbnail: String?
    let embassy_id: String?
    
    init?(dictionary: [String: Any]) {
        self.id = dictionary["id"] as! String
        self.text = dictionary["text"] as? String
        self.picture = dictionary["picture"] as! String
        self.picture_file_name = dictionary["picture_file_name"] as? String
        self.thumbnail = dictionary["thumbnail"] as? String
        self.embassy_id = dictionary["embassy_id"] as? String
    }
}
