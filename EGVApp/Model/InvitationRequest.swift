//
//  InvitationRequest.swift
//  EGVApp
//
//  Created by Fabricio on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

struct InvitationRequest {
    let id: String
    let leaderId: String
    let leaderName: String
    let requestorEmail: String
    let requestorName: String
    let requestorWhatsapp: String
    let embassy: Embassy?
}
