//
//  ListUsersVC.swift
//  EGVApp
//
//  Created by Fabricio on 10/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ListUsersVC: UIViewController {

    
    var mUser: User!
    private var mUsers: [User] = []
    private var mSelectedUser: User!
    private var mDatabase: Firestore?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mDatabase = MyFirebase.sharedInstance.database()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
