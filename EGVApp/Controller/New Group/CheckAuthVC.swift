//
//  CheckAuthVC.swift
//  EGVApp
//
//  Created by Fabrício Augusto on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class CheckAuthVC: UIViewController, LoginDelegate {
    
    private var mMessaging: Messaging?
    private var mAuth: Auth!
    private var mDatabase: Firestore?
    private var mUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mDatabase = MyFirebase.sharedInstance.database()
        mAuth = MyFirebase.sharedInstance.auth()
        mMessaging = MyFirebase.sharedInstance.messaging()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let loggedUser = mAuth.currentUser
        
        if let authUser = loggedUser {
            let uid = authUser.uid
            print("egvapplog", authUser.uid)
            getCurrentUser(uid: uid)
        } else {
            startLoginViewController()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CompleteRegisterVC
        vc.mUser = mUser
    }
    
    private func startLoginViewController() {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        loginVC.delegate = self
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func checkLogin(uid: String) {
        getCurrentUser(uid: uid)
    }
    
    private func getCurrentUser(uid: String) {
        mDatabase?.collection(MyFirebaseCollections.USERS).document(uid).getDocument(completion:
            { (documentSnapshot, error) in
                
                if let user = documentSnapshot.flatMap({
                    $0.data().flatMap({ (data) in
                        return User(dictionary: data)
                    })
                }) {
                    
                    if(user.last_device_os != "android") {
                        documentSnapshot?.reference.updateData(["last_device_os": "ios"])
                    }
                    
                    if(user.last_device_version != "version") {
                        documentSnapshot?.reference.updateData(["last_device_version": "version"])
                    }
                    
                    if(user.last_app_update != "14") {
                        documentSnapshot?.reference.updateData(["last_app_update": "14"])
                    }
                    
                    if(user.leader) {
                        self.mMessaging?.subscribe(toTopic: "egv_topic_leaders")
                    }
                    
                    self.mMessaging?.subscribe(toTopic: "egv_topic_members")
                    
                    
                    if(user.fcm_token != nil) {
                        //obterToken(documentSnapshot.reference)
                    }
                    
                    self.mUser = user
                    self.checkUser()
                    
                    print("User: \(user)")
                } else {
                    do {
                        try self.mAuth.signOut()
                        self.startLoginViewController()
                    } catch {
                        
                    }
                    
                }
        })
    }
    
    private func checkUser() {
    
    if(mUser.description == nil) {
        //startCompleteRegisterActivity()
        return
    } else if(mUser.profile_img == nil) {
        performSegue(withIdentifier: "completeRegisterSegue", sender: nil)
        return
    } else {
        performSegue(withIdentifier: "mainTabBarSegue", sender: nil)
        return
        }
    }
    
    private func startCompleteRegisterVC() {
        
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
