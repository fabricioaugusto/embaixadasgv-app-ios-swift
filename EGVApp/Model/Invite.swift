//
//  Invite.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

struct Invite {
    let id: String
    let name_sender: String
    let email_sender: String
    let name_receiver: String
    let email_receiver: String
    let embassy_receiver: Embassy
    let isLeader: Bool
    let isManager: Bool
    let invite_code: Int
}
