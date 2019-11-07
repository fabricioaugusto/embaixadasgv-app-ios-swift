//
//  Enrollment.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class Enrollment: Codable {
    let id: String
    let event_id: String
    let user_id: String
    let event_date: Timestamp?
    let event: Event
    let waiting_list: Bool
    let user: User
}
