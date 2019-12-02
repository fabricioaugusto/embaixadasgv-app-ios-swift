//
//  EditProfileVC.swift
//  EGVApp
//
//  Created by Fabricio on 19/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseAuth
import FirebaseFirestore
import GooglePlaces
import KMPlaceholderTextView
import JGProgressHUD

class EditProfileVC: UIViewController {

    
    @IBOutlet weak var svFormFields: UIStackView!
    @IBOutlet weak var mGenderSegmented: UISegmentedControl!
    @IBOutlet weak var mBiographyField: KMPlaceholderTextView!
    
    @IBOutlet weak var mBiographyContainer: UIView!
    
    var mUser: User!
    var mInvite: Invite!
    private var mAuth: Auth!
    private var mDatabase: Firestore!
    private var mNameField: SkyFloatingLabelTextField!
    private var mEmailField: SkyFloatingLabelTextField!
    private var mBirthDateField: SkyFloatingLabelTextField!
    private var mSearchCityField: SkyFloatingLabelTextField!
    private var mOccupationField: SkyFloatingLabelTextField!
    private var mHud: JGProgressHUD!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFields()
    mGenderSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.colorWhite], for: .normal)
    mGenderSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.colorWhite], for: .selected)
        
        
        
        mAuth = MyFirebase.sharedInstance.auth()
        mDatabase = MyFirebase.sharedInstance.database()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Registrando..."
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickSaveBt(_ sender: Any) {
        self.saveUserData()
    }
    
    @IBAction func onChangeGenderValue(_ sender: UISegmentedControl) {
        let selectedOption = sender.selectedSegmentIndex
        
        if (selectedOption == 0) {
            mUser.gender = "male"
        } else {
            mUser.gender = "female"
        }
    }
    
    
    private func addFields() {
        
        self.mNameField = buildTextField(placeholder: "Nome", icon: String.fontAwesomeIcon(name: .user))
        svFormFields.insertArrangedSubview(self.mNameField, at: 0)
        
        self.mEmailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
        svFormFields.insertArrangedSubview(self.mEmailField, at: 1)
        
        self.mBirthDateField = buildTextField(placeholder: "Data de Nascimento", icon: String.fontAwesomeIcon(name: .birthdayCake))
        svFormFields.insertArrangedSubview(self.mBirthDateField, at: 2)
        
        self.mSearchCityField = buildTextField(placeholder: "Cidade", icon: String.fontAwesomeIcon(name: .mapMarkerAlt))
        svFormFields.insertArrangedSubview(self.mSearchCityField, at: 3)
        
        self.mOccupationField = buildTextField(placeholder: "Área de atuação", icon: String.fontAwesomeIcon(name: .briefcase))
        svFormFields.insertArrangedSubview(self.mOccupationField, at: 4)
        
        if(mUser.gender == "male") {
            mGenderSegmented.selectedSegmentIndex = 0
        } else {
            mGenderSegmented.selectedSegmentIndex = 1
        }
        
        AppLayout.addLineToView(view: mBiographyContainer, position: .LINE_POSITION_BOTTOM, color: AppColors.colorGrey, width: 1.0)
        //svFormFields.insertArrangedSubview(self.mBiographyField!, at: 3)
        
        mBirthDateField.delegate = self
        mSearchCityField.delegate = self
        mOccupationField.delegate = self
        
        mSearchCityField.restorationIdentifier = "searchCityField"
        svFormFields.alignment = .fill
        svFormFields.distribution = .fill
        svFormFields.axis = .vertical
        svFormFields.spacing = 24
        
        bindData()
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
    
    private func bindData() {
        self.mNameField.text = mUser.name
        self.mEmailField.text = mUser.email
        self.mBirthDateField.text = mUser.birthdate
        self.mSearchCityField.text = mUser.city
        self.mOccupationField.text = mUser.occupation
        self.mBiographyField.text = mUser.description
    }
    
    private func saveUserData() {
        
        let name = mNameField.text ?? ""
        let email = mEmailField.text ?? ""
        let city = mUser.city ?? ""
        let gender = mUser.gender ?? ""
        let birthdate = mBirthDateField.text ?? ""
        let occupation = mOccupationField.text ?? ""
        let biography = mBiographyField.text ?? ""
        
        if(name.isEmpty || email.isEmpty || birthdate.isEmpty || occupation.isEmpty || biography.isEmpty
            || city.isEmpty || gender.isEmpty) {
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
        
        if(birthdate.count < 10) {
            makeAlert(message: "Preencha uma data de nascimento válida")
            return
        }
        
        self.mHud.show(in: self.view)
        
        mUser.name = name
        mUser.description = biography
        mUser.birthdate = birthdate
        mUser.occupation = occupation
        
        if(email != mUser.email) {
            
            mUser.email = email
            
            let user = mAuth.currentUser
            
            if let user = user {
                user.updateEmail(to: email) { (error) in
                    if(error == nil) {
                        self.mDatabase.collection(MyFirebaseCollections.USERS)
                            .document(self.mUser.id)
                            .setData(self.mUser.toMap(), completion: { (error) in
                                if let error = error {
                                    print(error.localizedDescription.description)
                                } else {
                                    self.mHud.dismiss()
                                }
                            })
                    }
                }
            }
        } else {
            self.mDatabase.collection(MyFirebaseCollections.USERS)
                .document(mUser.id)
                .setData(mUser.toMap(), completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription.description)
                    } else {
                        self.mHud.dismiss()
                    }
                })
        }
        
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension EditProfileVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        mSearchCityField?.text = place.name
        mUser.city = place.name
        
        if let components = place.addressComponents {
            for component in components {
                if(component.types[0] == "administrative_area_level_1") {
                    mUser.state = component.name
                    mUser.state_short = component.shortName
                }
            }
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


extension EditProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.restorationIdentifier == "searchCityField" {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            
            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue))!
            autocompleteController.placeFields = fields
            
            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            filter.type = .city
            autocompleteController.autocompleteFilter = filter
            
            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == mBirthDateField {
            if textField.text?.count == 2 || textField.text?.count == 5 {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    textField.text = textField.text! + "/"
                }
            }
            // check the condition not exceed 9 chars
            return !(textField.text!.count > 9 && (string.count ) > range.length)
        } else {
            return true
        }
    }
}
