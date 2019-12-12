//
//  ResetPasswordVC.swift
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

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var svFormFields: UIStackView!
    @IBOutlet weak var mBtSendCode: UIButton!
    
    private var mAuth: Auth!
    private var mInvite: Invite!
    private var mDatabase: Firestore!
    private var mEmailField: SkyFloatingLabelTextField!
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
    
    @IBAction func onClickBtBack(_ sender: UIButton) {
    
        self.dismiss(animated: true, completion: nil)
    }
    
        // Do any additional setup after loading the view.
        private func addFields() {
            
            self.mEmailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
            svFormFields.insertArrangedSubview(self.mEmailField!, at: 0)
            
            
            mEmailField?.delegate = self
            
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
        
        
        @IBAction func sendResetEmail(_ sender: UIButton) {
            
            let email = self.mEmailField.text ?? ""
            
            self.mHud.show(in: self.view)
            
            if(!email.isEmpty) {
                
                mAuth.sendPasswordReset(withEmail: email) { (error) in
                    if let error = error {
                        self.mEmailField.text = ""
                        self.mHud.dismiss()
                        self.makeAlert(title: "E-mail Inválido", message: "Este e-mail não foi encontrado em nossos cadastros")
                    } else {
                        self.mEmailField.text = ""
                        self.mHud.dismiss()
                        self.makeAlert(title: "E-mail enviado!", message: "Em instantes você receberá um e-mail com as instruções para a criação de uma nova senha")
                    }
                }
            }
        }
    
    
    private func makeAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let vc = segue.destination as! RegisterVC
            vc.mInvite = mInvite
        }
        
    }
    
    extension ResetPasswordVC: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
}
