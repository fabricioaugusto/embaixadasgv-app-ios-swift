//
//  MyFirebase.swift
//  EGVApp
//
//  Created by Fabrício Augusto on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import FirebaseStorage

class MyFirebase {
    
    static let sharedInstance = MyFirebase()
    static let collections = MyFirebaseCollections()
    private var firestore: Firestore
    private var authService: Auth
    private var messagingService: Messaging
    private var storageService: Storage
    
    // Declare an initializer
    // Because this class is singleton only one instance of this class can be created
    init() {
        firestore = Firestore.firestore()
        authService = Auth.auth()
        messagingService = Messaging.messaging()
        storageService = Storage.storage()
    }
    // Add a function
    
    func database() -> Firestore {
        return self.firestore
    }
    
    func auth() -> Auth {
        return self.authService
    }
    
    func messaging() -> Messaging {
        return self.messagingService
    }
    
    func storage() -> Storage {
        return self.storageService
    }
}

class MyFirebaseCollections {
    static let USERS = "users"
    static let EVENTS = "events"
    static let ENROLLMENTS = "enrollments"
    static let EMBASSY = "embassy"
    static let BULLETIN = "bulletins"
    static let COMMITTEES = "committees"
    static let NOTIFICATIONS = "notifications"
    static let EMBASSY_PHOTOS = "embassy_photos"
    static let LOCATIONS = "locations"
    static let POSTS = "posts"
    static let POST_LIKES = "post_likes"
    static let POST_COMMENTS = "post_comments"
    static let SPONSORS = "sponsors"
    static let APP_INVITATIONS = "app_invitations"
    static let APP_MESSAGES = "app_messages"
    static let APP_SERVER = "server_data"
    static let INVITATION_REQUEST = "invitation_request"
    static let APP_CONTENT = "app_content"
}
