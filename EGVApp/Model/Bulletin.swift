//
//  Bulletin.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class Bulletin: Codable {
    let id: String
    let type: String
    let date: Timestamp?
    let title: String?
    let resume: String?
    let text: String?
}
