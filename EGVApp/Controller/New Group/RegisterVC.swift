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

class RegisterVC: UIViewController {

    
    @IBOutlet weak var svFormFields: UIStackView!
    
    var mInvite: Invite!
    private var mAuth: Auth!
    private var mDatabase: Firestore!
    private var mUserField: SkyFloatingLabelTextField?
    private var mEmailField: SkyFloatingLabelTextField?
    private var mPasswordField: SkyFloatingLabelTextField?
    private var mConfirmPasswordField: SkyFloatingLabelTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFields()

        mAuth = MyFirebase.sharedInstance.auth()
        mDatabase = MyFirebase.sharedInstance.database()
        // Do any additional setup after loading the view.
    }
    
    private func registerUser() {
    
        let name = mUserField?.text
        let email = mEmailField?.text
        let pass = mPasswordField?.text
        let passConfirm = mConfirmPasswordField?.text
    
    
    
        if(validateRegister(name: name, email: email, pass: pass, passConfirm: passConfirm)) {
            if(email != mInvite.email_receiver) {
                //makeToast("Você deve cadastrar o mesmo e-mail em que o convite foi enviado")
                return
            }
            
            self.mAuth.createUser(withEmail: email!, password: pass!) { authResult, error in
                let user = authResult?.user
                
                if(user != nil) {
                    self.saveUser(id: user.uid!, name: name!, email: email!)
                }
            }
        }
    }
    
    private func saveUser(id: String, name: String, email: String) {
    
        let collection = mDatabase.collection(MyFirebaseCollections.USERS)
        
    
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
            user["embassy"] = embassy
            user["embassy_id"] = embassy.id
        }
    
        collection
            .document(id)
            .setData(user) { (error) in
                
        }
    
        if(self.mAuth.currentUser != nil) {
    
            mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
                .document(mInvite.id)
                .delete()
        
            var currentUser: [String:Any] = [:]
            currentUser["name"] = name
            currentUser["id"] = id
            currentUser["email"] = email
        
            
            if(mInvite.isLeader) {
                setEmbassy(currentUser: User(dictionary: currentUser)!)
            } else {
                setUsername(currentUser: User(dictionary: currentUser)!)
            }
        }
    
    }
    
    private func setUsername(currentUser: User) {
        
        let collection = mDatabase.collection(MyFirebaseCollections.USERS)
    
        let formatted_name = currentUser.name.folding(options: .diacriticInsensitive, locale: .current)
    
    
        let name_array = formatted_name.split(separator: " ")
        let name_size = name_array.count
    
        let fist_name = name_array[0]
        var last_name = ""
    
        if(name_size > 1) {
            last_name = name_array[name_size-1]
        }
    
        var username = "${fist_name}_${last_name}"
    
        if(name_size == 1) {
            username = fist_name
        }
    
        collection.whereEqualTo("username", username)
        .get()
        .addOnSuccessListener {
            querySnapshot ->
            if(querySnapshot.isEmpty) {
                collection.document(currentUser.id).update("username", username)
                .addOnSuccessListener {
                    startCheckAuthActivity()
                }
            } else {
                collection.document(currentUser.id).update("username", "${username}_${(100..999).random()}")
                .addOnSuccessListener {
                    startCheckAuthActivity()
                }
            }
        }
    }
    
    private func setEmbassy(currentUser: User) {
    
        if let embassy = mInvite.embassy_receiver {
            self.mDatabase.collection(MyFirebaseCollections.EMBASSY)
                .document(embassy.id)
                .updateData(["leader":currentUser, "leader_id":currentUser.id])
        }
        
    }
    
    private func validateRegister (name: String?, email: String?, pass: String?, passConfirm: String?) -> Bool {
    
        if (name!.isEmpty || email!.isEmpty || pass!.isEmpty || passConfirm!.isEmpty) {
            //makeToast("Preencha todos os campos!")
            return false
        }
    
        if(name!.contains("@")) {
            //makeToast("Por favor cadastre um nome válido!")
            return false
        }
    
        if(!email!.contains("@")) {
            //makeToast("Por favor cadastre um e-mail válido!")
            return false
        }
    
        if (pass!.count < 6) {
            //makeToast("A senha deve possuir mais de 6 caracteres!")
            return false
        }
    
        if (pass != passConfirm) {
            //makeToast("As senhas não conferem")
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
