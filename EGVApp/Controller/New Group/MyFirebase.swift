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
    
    // Declare an initializer
    // Because this class is singleton only one instance of this class can be created
    init() {
        FirebaseApp.configure()
        print("CloudCodeExecutor has been initialized")
    }
    // Add a function
    func processCloudCodeOperation() {
        print("Started processing cloud code operation")
    }
        // Your other code here
        
}
