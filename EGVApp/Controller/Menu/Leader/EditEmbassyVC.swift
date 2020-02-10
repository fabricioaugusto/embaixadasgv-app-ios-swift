//
//  EditEmbassyVC.swift
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

class EditEmbassyVC: UIViewController {

    @IBOutlet weak var svFormFields: UIStackView!
    @IBOutlet weak var mPickerView: UIPickerView!
    @IBOutlet weak var mViewContainerPicker: UIView!
    
    
    var mUser: User!
    var mEmbassyID: String!
    private var mEmbassy: Embassy!
    private var mDatabase: Firestore!
    private var mNameField: SkyFloatingLabelTextFieldWithIcon!
    private var mEmailField: SkyFloatingLabelTextFieldWithIcon!
    private var mPhoneField: SkyFloatingLabelTextFieldWithIcon!
    private var mNumberOfParticipants: SkyFloatingLabelTextFieldWithIcon!
    private var mHud: JGProgressHUD!
    private var mPickerData: [String] = ["Semanal", "Quinzenal", "Mensal"]
    private var mFrequencyList: [String] = ["weekly", "biweekly", "monthly"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mDatabase = MyFirebase.sharedInstance.database()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        addFields()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Registrando..."
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtSaveEmbassy(_ sender: UIBarButtonItem) {
        self.saveData()
    }
    
    
    private func addFields() {
        
        self.mNameField = buildTextField(placeholder: "Nome", icon: String.fontAwesomeIcon(name: .user))
        svFormFields.insertArrangedSubview(self.mNameField, at: 0)
        
        self.mEmailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
        self.mEmailField.keyboardType = .emailAddress
        self.mEmailField.textContentType = .emailAddress
        svFormFields.insertArrangedSubview(self.mEmailField, at: 1)
        
        self.mPhoneField = buildTextField(placeholder: "Telefone (Whatsapp)", icon: String.fontAwesomeIcon(name: .phone))
        mPhoneField.keyboardType = .phonePad
        svFormFields.insertArrangedSubview(self.mPhoneField, at: 2)
        
        mNumberOfParticipants = buildTextField(placeholder: "Média de Participantes por Encontro", icon: String.fontAwesomeIcon(name: .users))
        mNumberOfParticipants.keyboardType = .numberPad
        mNumberOfParticipants.iconFont = UIFont.fontAwesome(ofSize: 16, style: .solid)
        svFormFields.insertArrangedSubview(mNumberOfParticipants, at: 3)
        
        
        svFormFields.alignment = .fill
        svFormFields.distribution = .fill
        svFormFields.axis = .vertical
        svFormFields.spacing = 24
            
        getEmbassyDetails()
    }
    
    
    private func buildTextField(placeholder: String, icon: String) -> SkyFloatingLabelTextFieldWithIcon {
        
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
    
    private func getEmbassyDetails() {
        mDatabase.collection(MyFirebaseCollections.EMBASSY)
        .document(mEmbassyID)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    
                } else {
                    if let embassy = documentSnapshot.flatMap({$0.data().flatMap({ (data) in
                        return Embassy(dictionary: data)
                    })}) {
                        self.mEmbassy = embassy
                        self.bindData()
                    }
                }
        }
    }
    
    
    
    private func bindData() {
        self.mNameField.text = mEmbassy.name
        self.mEmailField.text = mEmbassy.email
        self.mPhoneField.text = mEmbassy.phone
        self.mNumberOfParticipants.text = "\(mEmbassy.members_quantity)"
        
        if mEmbassy.frequency == "weekly" {
            mPickerView.selectRow(0, inComponent: 0, animated: false)
        }
        
        if mEmbassy.frequency == "biweekly" {
            mPickerView.selectRow(1, inComponent: 0, animated: false)
        }
        
        if mEmbassy.frequency == "monthly" {
            mPickerView.selectRow(2, inComponent: 0, animated: false)
        }
    }
    
    
    private func saveData() {
        let name = mNameField.text ?? ""
        let email = mEmailField.text ?? ""
        let phone = mPhoneField.text ?? ""
        let number_of_participants = Int(mNumberOfParticipants.text  ?? "0")
        let frequency = mFrequencyList[mPickerView.selectedRow(inComponent: 0)]
        
        if(name.isEmpty || email.isEmpty || phone.isEmpty) {
            makeAlert(title: "Atenção", message: "Todos os campos devem ser preenchidos!")
            return
        }
        
        if(number_of_participants == 0) {
            makeAlert(title: "Atenção", message: "Você precisa informar o número de participantes por reunião")
            return
        }
        
        if(frequency.isEmpty) {
            makeAlert(title: "Atenção", message: "Você precisa informar a frequência dos encontros de sua embaixada")
            return
        }
        
        if(name.contains("@")) {
            makeAlert(title: "Atenção", message: "Por favor preencha um nome válido!")
            return
        }
        
        if(!email.contains("@")) {
            makeAlert(title: "Atenção", message: "Por favor preencha um e-mail válido!")
            return
        }
        
        self.mHud.show(in: self.view)
        
        let embassy: [String: Any] = [
            "name":name,
            "email":email,
            "phone":phone,
            "members_quantity": number_of_participants,
            "frequency":frequency]
        
        mDatabase.collection(MyFirebaseCollections.EMBASSY)
        .document(mEmbassyID)
            .updateData(embassy) { (error) in
                if error == nil {
                    self.mHud.dismiss()
                    self.makeAlert(title: "Dados atualizados", message: "Os dados da embaixada foram atualizados com sucesso!")
                }
        }
    }
    
    private func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
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




extension EditEmbassyVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mPickerData[row]
    }
    
    
}
