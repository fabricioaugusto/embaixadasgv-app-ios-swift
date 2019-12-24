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
import JGProgressHUD

protocol LoginDelegate: class {
    func checkLogin(uid: String, vc: LoginVC)
}

class LoginVC: UIViewController {

    @IBOutlet weak var mSVContainerLogin: UIStackView!
    @IBOutlet weak var mLoginBT: UIButton!
    @IBOutlet weak var mBtForgotPass: UIButton!
    
    private var mAuth: Auth?
    private var mEmailField: SkyFloatingLabelTextField!
    private var mPassField: SkyFloatingLabelTextField!
    private var mHud: JGProgressHUD!
    
    weak var delegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mAuth = MyFirebase.sharedInstance.auth()
        addFields()
        // Do any additional setup after loading the view.
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Entrando..."
    
    }
    
    @IBAction func loginPress(_ sender: UIButton) {
        loginUser()
    }
    
    
    private func addFields() {
        
        self.mEmailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
        self.mEmailField.keyboardType = .emailAddress
        self.mEmailField.textContentType = .emailAddress
        mSVContainerLogin.insertArrangedSubview(self.mEmailField, at: 0)
        
        self.mPassField = buildTextField(placeholder: "Senha", icon: String.fontAwesomeIcon(name: .lock))
        self.mPassField?.textContentType = .password
        self.mPassField?.isSecureTextEntry = true
        mSVContainerLogin.insertArrangedSubview(self.mPassField!, at: 1)
        
        
        mEmailField?.delegate = self
        mPassField?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        
        if(email.isEmpty || pass.isEmpty) {
            self.makeAlert(message: "Você precisa preenchar todos os campos para efetuar o login")
            return
        }
        
        self.mHud.show(in: self.view)
        
        self.mAuth?.signIn(withEmail: email, password: pass) { [weak self] user, error in
            guard self != nil else { return }
            if let credential = user {
                
                self?.mHud.dismiss()
                self?.delegate?.checkLogin(uid: credential.user.uid, vc: self!)
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.mHud.dismiss()
                self?.makeAlert(message: "Dados de login incorretos, tente novamente!")
            }
                // ...
        }
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Ops", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height-100
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
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
