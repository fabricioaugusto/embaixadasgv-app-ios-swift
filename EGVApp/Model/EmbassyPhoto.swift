//
//  EmbassyPhoto.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class EmbassyPhoto: Codable {
    let id: String
    let date: Timestamp?
    let text: String?
    let picture: String
    let picture_file_name: String?
    let thumbnail: String?
    let embassy_id: String?
}
