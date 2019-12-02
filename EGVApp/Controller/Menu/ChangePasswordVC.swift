//
//  ChangePasswordVC.swift
//  EGVApp
//
//  Created by Fabricio on 26/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var svFormFields: UIStackView!
    
    var mUser: User!
    private var mAuth: Auth!
    private var mDatabase: Firestore!
    private var mCurrentPassField: SkyFloatingLabelTextField!
    private var mNewPassField: SkyFloatingLabelTextField!
    private var mConfirmPassField: SkyFloatingLabelTextField!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFields()
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Salvando..."
        // Do any additional setup after loading the view.
    }
    
    private func addFields() {
        
        self.mCurrentPassField = buildTextField(placeholder: "Senha Atual", icon: String.fontAwesomeIcon(name: .lock))
        self.mCurrentPassField?.textContentType = .password
        self.mCurrentPassField?.isSecureTextEntry = true
        svFormFields.insertArrangedSubview(self.mCurrentPassField!, at: 0)
        
        self.mNewPassField = buildTextField(placeholder: "Nova Senha", icon: String.fontAwesomeIcon(name: .lock))
        self.mNewPassField?.textContentType = .password
        self.mNewPassField?.isSecureTextEntry = true
        svFormFields.insertArrangedSubview(self.mNewPassField!, at: 1)
        
        self.mConfirmPassField = buildTextField(placeholder: "Confirmar Senha", icon: String.fontAwesomeIcon(name: .lock))
        self.mConfirmPassField?.textContentType = .password
        self.mConfirmPassField?.isSecureTextEntry = true
        svFormFields.insertArrangedSubview(self.mConfirmPassField!, at: 2)
        
        //svFormFields.insertArrangedSubview(self.mBiographyField!, at: 3)
        
        
        svFormFields.alignment = .fill
        svFormFields.distribution = .fill
        svFormFields.axis = .vertical
        svFormFields.spacing = 24
        
    }
    
    
    private func buildTextField(placeholder: String, icon: String) -> SkyFloatingLabelTextField {
        
        let textField = SkyFloatingLabelTextFieldWithIcon(frame: CGRect(x: 10, y: 10, width: 120, height: 64))
        textField.placeholder = placeholder
        textField.title = placeholder
        textField.tintColor = AppColors.colorAccent// the color of the blinking cursor
        textField.textColor = AppColors.colorText
        textField.lineColor = AppColors.colorGrey
        textField.selectedTitleColor = AppColors.colorAccent
        textField.selectedLineColor = AppColors.colorAccent
        textField.lineHeight = 1.0 // bottom line height in points
        textField.iconFont = UIFont.fontAwesome(ofSize: 18, style: .solid)
        textField.iconText = icon
        textField.iconMarginBottom = 1
        textField.selectedLineHeight = 2.0
        
        return textField
    }
    
    @IBAction func onClickSaveBt(_ sender: Any) {
        setPassword()
    }

    private func setPassword() {
    
        let currentPass = mCurrentPassField.text ?? ""
        let newPass = mNewPassField.text ?? ""
        let confirmPass = mConfirmPassField.text ?? ""
        
        if(currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
            makeAlert(message: "Todos os campos devem ser preenchidos!")
            return
        }
    
        if(newPass != confirmPass) {
            makeAlert(message: "As senhas não conferem!")
            return
        }
    
        self.mHud.show(in: self.view)
        
        if let user = mAuth.currentUser {
            mAuth.signIn(withEmail: user.email!, password: currentPass) { (authDataResult, error) in
                if error == nil {
                    authDataResult?.user.updatePassword(to: newPass, completion: { (error) in
                        if error == nil {
                            self.mHud.dismiss()
                            self.makeAlert(message: "Senha alterada com sucesso!")
                        }
                    })
                } else {
                    self.mHud.dismiss()
                    self.makeAlert(message: "A senha atual está incorreta!")
                }
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
