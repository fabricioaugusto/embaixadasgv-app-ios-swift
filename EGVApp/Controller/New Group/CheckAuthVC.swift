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
    private var mLoginDone: Bool = false

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
            if(!mLoginDone) {
                getCurrentUser(uid: uid, login: false)
            }
        } else {
            startLoginViewController()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "completeRegisterSegue") {
            let vc = segue.destination as! CompleteRegisterVC
            vc.mUser = mUser
            return
        }
        
        if(segue.identifier == "chooseProfilePhotoSegue") {
            let vc = segue.destination as! ChooseProfilePhotoVC
            vc.mUser = mUser
            return
        }
        
        if(segue.identifier == "mainTabBarSegue") {
            let barViewControllers = segue.destination as! UITabBarController
            
            let dashboardTab = barViewControllers.viewControllers![0] as! UINavigationController
            let dashboardVC = dashboardTab.topViewController as! RootDashboardVC
            dashboardVC.mUser = mUser
            
            let usersTab = barViewControllers.viewControllers![1] as! UINavigationController
            let usersVC = usersTab.topViewController as! RootUsersTableVC
            usersVC.mUser = mUser
            
            let contentTab = barViewControllers.viewControllers![2] as! UINavigationController
            let contentVC = contentTab.topViewController as! RootPostsTableVC
            contentVC.mUser = mUser
            
            let agendaTab = barViewControllers.viewControllers![3] as! UINavigationController
            let agendaVC = agendaTab.topViewController as! RootAgendaTableVC
            agendaVC.mUser = mUser
            
            let menuTab = barViewControllers.viewControllers![4] as! UINavigationController
            let menuVC = menuTab.topViewController as! RootMenuTableVC
            menuVC.mUser = mUser
        }
    }
    
    private func startLoginViewController() {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        loginVC.delegate = self
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func checkLogin(uid: String, vc: LoginVC) {
        self.mLoginDone = true
        getCurrentUser(uid: uid, login: true)
    }
    
    private func getCurrentUser(uid: String, login: Bool) {
        mDatabase?.collection(MyFirebaseCollections.USERS).document(uid).getDocument(completion:
            { (documentSnapshot, error) in
                
                if let user = documentSnapshot.flatMap({
                    $0.data().flatMap({ (data) in
                        return User(dictionary: data)
                    })
                }) {
                    
                    if(user.last_device_os != "ios") {
                        documentSnapshot?.reference.updateData(["last_device_os": "ios"])
                    }
                    
                    if(user.last_device_version != "version") {
                        documentSnapshot?.reference.updateData(["last_device_version": "version"])
                    }
                    
                    if(user.last_app_update != "2") {
                        documentSnapshot?.reference.updateData(["last_app_update": "2"])
                    }
                    
                    if(user.fcm_token != nil) {
                        //obterToken(documentSnapshot.reference)
                    }
                    
                    self.mUser = user
                    
                    if(login) {
                        if(self.mUser.leader) {
                            FIRMessagingService.shared.subscribe(to: .leaders)
                        }
                        FIRMessagingService.shared.subscribe(to: .members)
                        FIRMessagingService.shared.subscribe(to: .ios)
                    }
                    
                    self.checkUser()
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
            performSegue(withIdentifier: "completeRegisterSegue", sender: nil)
            return
        } else if(mUser.profile_img == nil) {
            performSegue(withIdentifier: "chooseProfilePhotoSegue", sender: nil)
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
