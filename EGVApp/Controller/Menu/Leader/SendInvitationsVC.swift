//
//  SendInvitationsVC.swift
//  EGVApp
//
//  Created by Fabricio on 11/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseFirestore
import JGProgressHUD

class SendInvitationsVC: UIViewController {

    
    @IBOutlet weak var mBtWhatsapp: UIButton!
    @IBOutlet weak var mBtCopy: UIButton!
    @IBOutlet weak var mBtGenerateCode: UIButton!
    @IBOutlet weak var mBtNewCode: UIButton!
       
    @IBOutlet weak var mViewCodeContainer: UIView!
    @IBOutlet weak var mViewShareOptions: UIView!
    @IBOutlet weak var mLbCode: UILabel!
    @IBOutlet weak var mLbShareCodeText: UILabel!
    
    @IBOutlet weak var mViewLinkContainer: UIView!
    @IBOutlet weak var mSvFormField: UIStackView!
    @IBOutlet weak var mLbInvitationLink: UILabel!
    
   
    var mUser: User!
    private var mDatabase: Firestore!
    private var mNameField: SkyFloatingLabelTextField!
    private var mEmailField: SkyFloatingLabelTextField!
    private var mHud: JGProgressHUD!
    private var mCurrentInviteID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mDatabase = MyFirebase.sharedInstance.database()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Enviando..."
        
        addFields()
        
        mViewLinkContainer.layer.cornerRadius = 5
        mViewLinkContainer.layer.masksToBounds = true
        mViewLinkContainer.layer.borderColor = AppColors.colorGrey.cgColor
        mViewLinkContainer.layer.borderWidth = 1.0
        
        let username: String = mUser.username ?? ""
        mLbInvitationLink.text = "https://embaixadasgv.app/convite/\(username)"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtSendInvitation(_ sender: UIButton) {
        self.saveData()
    }
    
    
    @IBAction func onClickBtWhatsapp(_ sender: Any) {
        
        let name = mNameField.text ?? ""
        let text = "Olá *\(name)*, este é um convite para você ter acesso ao aplicativo das Embaixadas GV. Bastar baixar o *EGV App* na Google Play (para Android) ou na AppStore (para iOS), clicar em *CADASTRE-SE* e utilizar o seguinte código de acesso: *\(mLbCode.text ?? "")*. Vamos lá? https://embaixadasgv.app"
        
        let escapedString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        print(escapedString!)
        
        //print(message)
        
        let url = URL(string: "https://wa.me/?text=\(escapedString!)")
        
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func onClickBtCopy(_ sender: UIButton) {
        
        let name = mNameField.text ?? ""
        let text = "Olá \(name), este é um convite para você ter acesso ao aplicativo das Embaixadas GV. Bastar baixar o EGV App na Google Play (para Android) ou na AppStore (para iOS), clicar em CADASTRE-SE e utilizar o seguinte código de acesso: \(mLbCode.text ?? ""). Vamos lá? https://embaixadasgv.app"
        
        UIPasteboard.general.string = text
        
        let alert = UIAlertController(title: "Texto do convite copiado!", message: "Agora você pode colar no Mensager do Facebook, Direct do Instagram, Telegram ou onde preferir", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func onClickNewCode(_ sender: UIButton) {
        mViewCodeContainer.isHidden = true
        mLbShareCodeText.isHidden = true
        mViewShareOptions.isHidden = true
        mNameField.text = ""
        mEmailField.text = ""
        mBtNewCode.isHidden = true
        mNameField.isHidden = false
        mEmailField.isHidden = false
        mBtGenerateCode.isHidden = false
    }
    
    @IBAction func onClickBtCopyLink(_ sender: Any) {
        
        let username: String = mUser.username ?? ""
        
        UIPasteboard.general.string = "https://embaixadasgv.app/convite/\(username)"
        
        let alert = UIAlertController(title: "Link Copiado", message: "O link foi copiado com sucesso!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addFields() {
        
        self.mNameField = buildTextField(placeholder: "Nome", icon: String.fontAwesomeIcon(name: .user))
        mSvFormField.insertArrangedSubview(self.mNameField, at: 0)
        self.mNameField.delegate = self
        
        self.mEmailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
        self.mEmailField.keyboardType = .emailAddress
        self.mEmailField.textContentType = .emailAddress
        mSvFormField.insertArrangedSubview(self.mEmailField, at: 1)
        self.mEmailField.delegate = self
        
        mSvFormField.alignment = .fill
        mSvFormField.distribution = .fill
        mSvFormField.axis = .vertical
        mSvFormField.spacing = 24
        
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
    
    private func saveData() {
        let name = mNameField.text ?? ""
        let email = mEmailField.text ?? ""
        
        if(name.isEmpty || email.isEmpty) {
            makeAlert(message: "Todos os campos devem ser preenchidos!")
            return
        }
        
        if(name.contains("@")) {
            makeAlert(message: "Por favor preencha um nome válido!")
            return
        }
        
        if(!email.contains("@")) {
            makeAlert(message: "Por favor preencha um e-mail válido!")
            return
        }
        
        mHud.show(in: self.view)
        
        let code: Int = Int.random(in: 100000..<999999)

        let invite: [String : Any] = [
            "name_sender" : mUser.name,
            "email_sender" : mUser.email,
            "name_receiver" : name,
            "email_receiver" : email,
            "embassy_receiver" : mUser.embassy!.toBasicMap(),
            "invite_code" : code
        ]

        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
            .whereField("email_receiver", isEqualTo: email)
            .getDocuments { (querySnapshot, error) in
                if let query = querySnapshot {
                    if query.documents.count > 0 {
                        self.mHud.dismiss()
                        self.makeAlert(message: "Um convite já foi enviado para este e-mail")
                    } else {
                        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
                        .document("\(code)")
                        .setData(invite) { (error) in
                                
                            if error == nil {
                                self.mNameField.isHidden = true
                                self.mEmailField.isHidden = true
                                
                                self.mCurrentInviteID = "\(code)"
                                
                                self.mBtGenerateCode.isHidden = true
                                self.mBtNewCode.isHidden = false
                                                                
                                self.mLbCode.text = "\(code)"
                                self.mLbShareCodeText.text = "Você também pode escolher uma opção abaixo para enviar o código para \(name)"
                                self.mLbShareCodeText.isHidden = false
                                
                                self.mViewCodeContainer.isHidden = false
                                self.mViewShareOptions.isHidden = false
                                
                                self.mHud.dismiss()
                                
                                self.mHud.dismiss()
                                 let alert = UIAlertController(title: "Convite Enviado!", message: "O convite foi enviado com sucesso!", preferredStyle: UIAlertController.Style.alert)
                                 alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                 self.present(alert, animated: true, completion: nil)
                            }
                                
                        }
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

extension SendInvitationsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
