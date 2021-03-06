//
//  SubmitInviteCodeVC.swift
//  EGVApp
//
//  Created by Fabrício Augusto on 06/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

class SubmitInviteCodeVC: UIViewController {
    
    @IBOutlet weak var svFormFields: UIStackView!
    @IBOutlet weak var mBtSendCode: UIButton!
    
    private var mAuth: Auth!
    private var mInvite: Invite!
    private var mDatabase: Firestore!
    private var mCodeField: SkyFloatingLabelTextField?
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mAuth = MyFirebase.sharedInstance.auth()
        self.mDatabase = MyFirebase.sharedInstance.database()
        addFields()
        // Do any additional setup after loading the view.
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Enviando"
        
    }
    
    @IBAction func onClickRequestCode(_ sender: UIButton) {
        let url = URL(string: "https://embaixadasgv.app/quero-participar")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func onClickBtBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    private func addFields() {
        
        self.mCodeField = buildTextField(placeholder: "Código", icon: String.fontAwesomeIcon(name: .chevronRight))
        svFormFields.insertArrangedSubview(self.mCodeField!, at: 0)
        
        
        mCodeField?.delegate = self
        
        svFormFields.alignment = .fill
        svFormFields.distribution = .fill
        svFormFields.axis = .vertical
        svFormFields.spacing = 16
    }
    
    private func buildTextField(placeholder: String, icon: String) -> SkyFloatingLabelTextField {
        
        let textField = SkyFloatingLabelTextFieldWithIcon(frame: CGRect(x: 10, y: 10, width: 120, height: 64))
        textField.placeholder = placeholder
        textField.title = placeholder
        textField.tintColor = AppColors.colorAccent// the color of the blinking cursor
        textField.textColor = AppColors.colorWhite
        textField.lineColor = AppColors.colorGrey
        textField.selectedTitleColor = AppColors.colorAccent
        textField.selectedLineColor = AppColors.colorAccent
        textField.lineHeight = 1.0 // bottom line height in points
        textField.iconFont = UIFont.fontAwesome(ofSize: 18, style: .solid)
        textField.iconText = icon
        textField.selectedLineHeight = 2.0
        
        return textField
    }
    
    
    @IBAction func sendCode(_ sender: UIButton) {
        let code: String = self.mCodeField?.text ?? ""
        
        if(code.isEmpty) {
            print("Você deve preencher todos os campos")
            return
        }
        
        self.mHud.show(in: self.view)
        
        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
            .document(code)
            .getDocument(completion: { (documentSnapshot, error) in
                
                if let invite = documentSnapshot.flatMap({
                    $0.data().flatMap({ (data) in
                        return Invite(dictionary: data)
                    })
                }) {
                    self.mInvite = invite
                    self.mInvite.id = documentSnapshot!.documentID
                   
                    self.mHud.dismiss()
                    self.performSegue(withIdentifier: "registerSegue", sender: nil)
                    
                } else {
                    print("Document does not exist")
                }
            })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! RegisterVC
        vc.mInvite = mInvite
    }

}

extension SubmitInviteCodeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
