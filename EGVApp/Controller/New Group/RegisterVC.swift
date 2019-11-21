//
//  RegisterVC.swift
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

class RegisterVC: UIViewController {

    
    @IBOutlet weak var svFormFields: UIStackView!
    
    var mInvite: Invite!
    private var mAuth: Auth!
    private var mDatabase: Firestore!
    private var mUserField: SkyFloatingLabelTextField!
    private var mEmailField: SkyFloatingLabelTextField!
    private var mPasswordField: SkyFloatingLabelTextField!
    private var mConfirmPasswordField: SkyFloatingLabelTextField!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFields()

        mAuth = MyFirebase.sharedInstance.auth()
        mDatabase = MyFirebase.sharedInstance.database()
        // Do any additional setup after loading the view.
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Registrando..."
    }
    
    @IBAction func onClickRegisterBt(_ sender: UIButton) {
        registerUser()
    }
    
    
    private func registerUser() {
    
        let name = mUserField.text ?? ""
        let email = mEmailField.text ?? ""
        let pass = mPasswordField.text ?? ""
        let passConfirm = mConfirmPasswordField.text ?? ""
    
    
    
        if(validateRegister(name: name, email: email, pass: pass, passConfirm: passConfirm)) {
            if(email != mInvite.email_receiver) {
                makeAlert(message: "Você deve cadastrar o mesmo e-mail em que o convite foi enviado")
                return
            }
            
            self.mHud.show(in: self.view)
            
            self.mAuth.createUser(withEmail: email, password: pass) { authResult, error in
                
                if let user = authResult?.user {
                    self.saveUser(id: user.uid, name: name, email: email)
                }
            }
        }
    }
    
    private func saveUser(id: String, name: String, email: String) {
    
        let collection = mDatabase.collection(MyFirebaseCollections.USERS)
        print("egvapplog", "saveUser")
        
    
        var user: [String:Any] = [:]
        user["id"] = id
        user["name"] = name
        user["email"] = email
        user["status"] = "registered"
        user["last_read_notification"] = FieldValue.serverTimestamp()
    
    
        if(mInvite.isLeader) {
            user["leader"] = true
        }
    
        if let embassy = mInvite.embassy_receiver {
            user["embassy"] = embassy.toBasicMap()
            user["embassy_id"] = embassy.id
        }
    
        collection
            .document(id)
            .setData(user) { (error) in
                
                if let error = error {
                    print("egvapplog", "setDataError")
                    print(error.localizedDescription.description)
                } else {
                    print("egvapplog", "deu certo")
                    if(self.mAuth.currentUser != nil) {
                
                        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
                            .document(self.mInvite.id)
                            .delete()
                    
                        if(self.mInvite.isLeader) {
                            self.setEmbassy(currentUser: User(dictionary: user)!)
                        } else {
                            self.setUsername(currentUser: User(dictionary: user)!)
                        }
                    }
                }
        }
    
    }
    
    private func setUsername(currentUser: User) {
        print("egvapplog", currentUser)
        let collection = mDatabase.collection(MyFirebaseCollections.USERS)
    
        let formatted_name = currentUser.name.folding(options: .diacriticInsensitive, locale: .current)
    
    
        let name_array = formatted_name.components(separatedBy: " ")
        let name_size = name_array.count
    
        let fist_name = name_array[0]
        var last_name = ""
    
        if(name_size > 1) {
            last_name = name_array[name_size-1]
        }
    
        var username = "\(fist_name)_\(last_name)".lowercased()
    
        if(name_size == 1) {
            username = fist_name.lowercased()
        }
    
        collection.whereField("username", isEqualTo: username)
            .getDocuments(completion: { (querySnapshot, error) in
                if(querySnapshot?.count == 0) {
                    collection.document(currentUser.id).updateData(["username": username]) { (error) in
                        if let err = error {
                            print("Error updating document: \(err)")
                        } else {
                            self.mHud.dismiss()
                            self.startCheckAuthVC()
                        }
                    }
                } else {
                    collection.document(currentUser.id).updateData(["username": "\(username)_\(Int.random(in: 100..<999))"]) { (error) in
                        if let err = error {
                            print("Error updating document: \(err)")
                        } else {
                            self.mHud.dismiss()
                            self.startCheckAuthVC()
                        }
                    }
                }
            })

    }
    
    private func setEmbassy(currentUser: User) {
    
        if let embassy = mInvite.embassy_receiver {
            self.mDatabase.collection(MyFirebaseCollections.EMBASSY)
                .document(embassy.id)
                .updateData(["leader":currentUser, "leader_id":currentUser.id], completion: { (error) in
                    if let error = error {
                        
                    } else {
                        self.setUsername(currentUser: currentUser)
                    }
                })
        }
        
    }
    
    private func validateRegister (name: String, email: String, pass: String, passConfirm: String) -> Bool {
    
        if (name.isEmpty || email.isEmpty || pass.isEmpty || passConfirm.isEmpty) {
            makeAlert(message: "Preencha todos os campos!")
            return false
        }
    
        if(name.contains("@")) {
            makeAlert(message: "Por favor cadastre um nome válido!")
            return false
        }
    
        if(!email.contains("@")) {
            makeAlert(message: "Por favor cadastre um e-mail válido!")
            return false
        }
    
        if (pass.count < 6) {
            makeAlert(message: "A senha deve possuir mais de 6 caracteres!")
            return false
        }
    
        if (pass != passConfirm) {
            makeAlert(message: "As senhas não conferem")
            return false
        }
    
        return true
    }
    
    private func addFields() {
        
        self.mUserField = buildTextField(placeholder: "Usuário", icon: String.fontAwesomeIcon(name: .user))
        svFormFields.insertArrangedSubview(self.mUserField!, at: 0)
        
        self.mEmailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
        svFormFields.insertArrangedSubview(self.mEmailField!, at: 1)
        
        self.mPasswordField = buildTextField(placeholder: "Senha", icon: String.fontAwesomeIcon(name: .lock))
        self.mPasswordField?.textContentType = .password
        self.mPasswordField?.isSecureTextEntry = true
        svFormFields.insertArrangedSubview(self.mPasswordField!, at: 2)
        
        self.mConfirmPasswordField = buildTextField(placeholder: "Confirmar Senha", icon: String.fontAwesomeIcon(name: .lock))
        self.mConfirmPasswordField?.textContentType = .password
        self.mConfirmPasswordField?.isSecureTextEntry = true
        svFormFields.insertArrangedSubview(self.mConfirmPasswordField!, at: 3)
        
        mUserField?.delegate = self
        mEmailField?.delegate = self
        mPasswordField?.delegate = self
        mConfirmPasswordField?.delegate = self
        
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
        textField.lineColor = AppColors.colorWhite
        textField.selectedTitleColor = AppColors.colorAccent
        textField.selectedLineColor = AppColors.colorAccent
        textField.lineHeight = 1.0 // bottom line height in points
        textField.iconFont = UIFont.fontAwesome(ofSize: 18, style: .solid)
        textField.iconText = icon
        textField.selectedLineHeight = 2.0
        
        return textField
    }
    
    private func startCheckAuthVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckAuthVC") as! CheckAuthVC
        UIApplication.shared.keyWindow?.rootViewController = vc
        return
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

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
