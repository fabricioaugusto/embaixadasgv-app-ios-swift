//
//  SuggestFeaturesVC.swift
//  EGVApp
//
//  Created by Fabricio on 26/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseFirestore
import JGProgressHUD
import KMPlaceholderTextView

class SuggestFeaturesVC: UIViewController {

    @IBOutlet weak var mMessageField: KMPlaceholderTextView!
    @IBOutlet weak var svFormFields: UIStackView!
    @IBOutlet weak var mMessageContainer: UIView!
    
    var mUser: User!
    private var mDatabase: Firestore!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppLayout.addLineToView(view: mMessageContainer, position: .LINE_POSITION_BOTTOM, color: AppColors.colorGrey, width: 1.0)
        mDatabase = MyFirebase.sharedInstance.database()
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Enviando..."
    }

    @IBAction func onClickBtSendMessage(_ sender: UIBarButtonItem) {
        
        self.sendMessage()
    }
    
    
    private func sendMessage() {
        
        let message = mMessageField.text ?? ""
        
        if(message.isEmpty) {
            self.makeAlert(message: "Campo da mensagem está vazio!")
            return
        }
        
        self.mHud.show(in: self.view)
        
        let appMessage: [String: Any] = ["user_id" : mUser.id,
                                         "user_city" : mUser.city!,
                                         "user_embassy" : mUser.embassy?.name,
                                         "type" : "suggestion",
                                         "message" : message,
                                         "user" : mUser.toBasicMap()]
        
        mDatabase.collection(MyFirebaseCollections.APP_MESSAGES)
            .addDocument(data: appMessage) { (error) in
                if let error = error {
                    
                } else {
                    self.mMessageField.text = ""
                    self.mHud.dismiss()
                    self.makeAlert(message: "Mensagem enviada com sucesso!")
                }
        }
        
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
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

extension SuggestFeaturesVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
