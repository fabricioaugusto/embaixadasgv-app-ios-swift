//
//  SendInviteToInfluencersVC.swift
//  EGVApp
//
//  Created by Fabricio on 18/01/20.
//  Copyright © 2020 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseFirestore
import JGProgressHUD

class SendInviteToInfluencersVC: UIViewController {

    @IBOutlet weak var mBtWhatsapp: UIButton!
    @IBOutlet weak var mBtEmail: UIButton!
    @IBOutlet weak var mBtCopy: UIButton!
    @IBOutlet weak var mBtGenerateCode: UIButton!
    @IBOutlet weak var mBtNewCode: UIButton!
    
    
    @IBOutlet weak var mSvFormField: UIStackView!
    @IBOutlet weak var mViewCodeContainer: UIView!
    @IBOutlet weak var mSvShareOptions: UIStackView!
    @IBOutlet weak var mLbCode: UILabel!
    @IBOutlet weak var mLbShareCodeText: UILabel!
    
    
     var mUser: User!
     private var mDatabase: Firestore!
     private var mNameField: SkyFloatingLabelTextField!
     private var mHud: JGProgressHUD!
     private var mCurrentInviteID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        mDatabase = MyFirebase.sharedInstance.database()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Enviando..."
        
        mBtWhatsapp.layer.cornerRadius = 28
        mBtEmail.layer.cornerRadius = 28
        mBtCopy.layer.cornerRadius = 28
        
        addFields()
    }
    
    @IBAction func onClickGenerateCode(_ sender: UIButton) {
        self.saveData()
    }
    
    @IBAction func onClickBtWhatsapp(_ sender: Any) {
        
        let name = mNameField.text ?? ""
        let text = "Olá *\(name)*, este é um convite para você ter acesso ao aplicativo das Embaixadas GV. Bastar baixar o *EGV App* na Google Play (para Android) ou na AppStore (para iOS), clicar em *CADASTRE-SE* e utilizar o seguinte código de acesso: *\(mLbCode.text ?? "")*. Vamos lá? https://embaixadasgv.app"
        
        let message = text.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        let escapedString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        print(escapedString!)
        
        //print(message)
        
        let url = URL(string: "https://wa.me/?text=\(escapedString!)")
        
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func onClickBtEmail(_ sender: UIButton) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enviar por e-mail", message: "Digite o e-mail no campo abaixo para enviar o convite", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Enviar", style: .default, handler: { [weak alert] (_) in
            
            self.mHud.show(in: self.view)
            
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
           
            self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
                .document(self.mCurrentInviteID)
                .updateData(["email_receiver":textField!.text ?? "", "email_resent": true]) { (error) in
                    self.mHud.dismiss()
                    let alert = UIAlertController(title: "E-mail enviado!", message: "E-mail enviado com sucesso!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        
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
        mSvShareOptions.isHidden = true
        mNameField.text = ""
        mBtNewCode.isHidden = true
        mNameField.isHidden = false
        mBtGenerateCode.isHidden = false
    }
    
    
    private func addFields() {
        
        self.mNameField = buildTextField(placeholder: "Nome", icon: String.fontAwesomeIcon(name: .user))
        mNameField.delegate = self
        mSvFormField.insertArrangedSubview(self.mNameField, at: 0)
        
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
        
        if(name.isEmpty) {
            makeAlert(message: "Todos os campos devem ser preenchidos!")
            return
        }
        
        if(name.contains("@")) {
            makeAlert(message: "Por favor preencha um nome válido!")
            return
        }
        
        
        mHud.show(in: self.view)
        
        let code: Int = Int.random(in: 100000..<999999)

        let invite: [String : Any] = [
            "name_sender" : mUser.name,
            "email_sender" : mUser.email,
            "name_receiver" : name,
            "email_receiver" : "embaixadainfluenciadores@gmail.com",
            "influencer": true,
            "embassy_receiver" : mUser.embassy!.toBasicMap(),
            "invite_code" : code,
            "created_at" : FieldValue.serverTimestamp()
        ]
        
        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
            .document("\(code)")
            .setData(invite) { (error) in
                
                if error == nil {
                    
                    self.mCurrentInviteID = "\(code)"
                    
                    self.mBtGenerateCode.isHidden = true
                    self.mBtNewCode.isHidden = false
                    
                    self.mNameField.isHidden = true
                    
                    self.mLbCode.text = "\(code)"
                    self.mLbShareCodeText.text = "Escolha uma opção para enviar o código para \(name)"
                    self.mLbShareCodeText.isHidden = false
                    
                    self.mViewCodeContainer.isHidden = false
                    self.mSvShareOptions.isHidden = false
                    
                    self.mHud.dismiss()
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

extension SendInviteToInfluencersVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
