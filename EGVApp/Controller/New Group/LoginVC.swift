//
//  LoginVC.swift
//  EGVApp
//
//  Created by Fabricio on 05/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseAuth


protocol LoginDelegate: class {
    func checkLogin(uid: String)
}

class LoginVC: UIViewController {

    @IBOutlet weak var mSVContainerLogin: UIStackView!
    @IBOutlet weak var mLoginBT: UIButton!
    @IBOutlet weak var mBtForgotPass: UIButton!
    
    private var mAuth: Auth?
    private var mEmailField: SkyFloatingLabelTextField?
    private var mPassField: SkyFloatingLabelTextField?
    
    weak var delegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mAuth = MyFirebase.sharedInstance.auth()
        addFields()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginPress(_ sender: UIButton) {
        loginUser()
    }
    
    
    private func addFields() {
        
        self.mEmailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
        mSVContainerLogin.insertArrangedSubview(self.mEmailField!, at: 0)
        
        self.mPassField = buildTextField(placeholder: "Senha", icon: String.fontAwesomeIcon(name: .lock))
        self.mPassField?.textContentType = .password
        self.mPassField?.isSecureTextEntry = true
        mSVContainerLogin.insertArrangedSubview(self.mPassField!, at: 1)
        
        
        mEmailField?.delegate = self
        mPassField?.delegate = self
        
        mSVContainerLogin.alignment = .fill
        mSVContainerLogin.distribution = .fill
        mSVContainerLogin.axis = .vertical
        mSVContainerLogin.spacing = 16
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
        textField.iconFont = UIFont.fontAwesome(ofSize: 14, style: .solid)
        textField.iconText = icon
        textField.selectedLineHeight = 2.0
        
        return textField
    }
    
    private func loginUser() {
    
        let email: String = self.mEmailField!.text ?? ""
        let pass: String =  self.mPassField!.text ?? ""
    
        self.mAuth?.signIn(withEmail: email, password: pass) { [weak self] user, error in
            guard self != nil else { return }
            if let credential = user {
                self?.delegate?.checkLogin(uid: credential.user.uid)
                self?.dismiss(animated: true, completion: nil)
            }
                // ...
        }
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

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
