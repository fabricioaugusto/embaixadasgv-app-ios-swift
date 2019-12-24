//
//  FIRMessagingService.swift
//  EGVApp
//
//  Created by Fabricio on 19/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import FirebaseMessaging

enum SubscriptionTopic: String {
    case ios = "egv_topic_ios"
    case members = "egv_topic_members"
    case leaders = "egv_topic_leaders"
}

class FIRMessagingService {
    private init(){}
    static let shared = FIRMessagingService()
    let messaging = Messaging.messaging()
    
    func subscribe(to topic: SubscriptionTopic) {
        messaging.subscribe(toTopic: topic.rawValue)
    }
    
    func unsubscribe(to topic: SubscriptionTopic) {
        messaging.subscribe(toTopic: topic.rawValue)
    }
}
