//
//  MyFirebase.swift
//  EGVApp
//
//  Created by Fabrício Augusto on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation
import Firebase

class MyFirebase {
    
    static let sharedInstance = MyFirebase()
    private var firestore: Firestore
    private var authService: Auth
    private var messagingService: Messaging
    private var storageService: Storage
    
    // Declare an initializer
    // Because this class is singleton only one instance of this class can be created
    init() {
        FirebaseApp.configure()
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
