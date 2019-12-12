//
//  SetPrivacyVC.swift
//  EGVApp
//
//  Created by Fabricio on 26/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import JGProgressHUD

class SetPrivacyVC: UIViewController {

    var mUser: User!
    private var mDatabase: Firestore!
    private var mAuth: Auth!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mDatabase = MyFirebase.sharedInstance.database()
        mAuth = MyFirebase.sharedInstance.auth()
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Excluindo..."
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickRemoveAccount(_ sender: UIButton) {
        self.makeAlert(message: "Tem certeza que deseja remover a sua conta? Esta ação é irreversível!")
    }
    
    private func deleteAccount() {
        
        mHud.show(in: self.view)
        
        self.mDatabase.collection(MyFirebaseCollections.USERS).document(mUser.id)
            .delete { (error) in
                if error == nil {
                    do {
                        self.mHud.dismiss()
                        try self.mAuth.signOut()
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckAuthVC") as! CheckAuthVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        return
                    } catch {
                        print("Não foi possível fazer o logoff")
                    }
                }
            }
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Excluir conta", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sim, tenho certeza", style: UIAlertAction.Style.destructive, handler: { (alertAction) in
            self.deleteAccount()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
