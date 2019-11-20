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

class EditProfileVC: UIViewController {

    
    @IBOutlet weak var svFormFields: UIStackView!
    
    @IBOutlet weak var mGenderSegmented: UISegmentedControl!
        
    private var mUser: User!
    private var mAuth: Auth!
    private var mDatabase: Firestore!
    private var mNameField: SkyFloatingLabelTextField!
    private var mEmailField: SkyFloatingLabelTextField!
    private var mBirthDateField: SkyFloatingLabelTextField!
    private var mSearchCityField: SkyFloatingLabelTextField!
    private var mOccupationField: SkyFloatingLabelTextField!
    private var mBiographyField: SkyFloatingLabelTextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFields()
        mGenderSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.colorWhite], for: .normal)
        
        mGenderSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.colorWhite], for: .selected)
        // Do any additional setup after loading the view.
    }
    
    private func getUserDetails() {

        mNameField.text = mUser.name
        mEmailField.text = mUser.email

        if(mUser.birthdate != nil) {
            self.mBirthDateField.text = mUser.birthdate
        }

        if(mUser.city != nil) {
            self.mSearchCityField.text = mUser.city
        }

        if(mUser.occupation != nil) {
            self.mOccupationField.text = mUser.occupation
        }

        if(mUser.description != nil) {
            self.mBiographyField.text = mUser.description
        }
    }

    
    private func addFields() {
            
            self.mBirthDateField = buildTextField(placeholder: "Data de Nascimento", icon: String.fontAwesomeIcon(name: .user))
            svFormFields.insertArrangedSubview(self.mBirthDateField!, at: 0)
            
            self.mSearchCityField = buildTextField(placeholder: "Cidade", icon: String.fontAwesomeIcon(name: .envelope))
            svFormFields.insertArrangedSubview(self.mSearchCityField!, at: 1)
            
            self.mOccupationField = buildTextField(placeholder: "Área de atuação", icon: String.fontAwesomeIcon(name: .lock))
            svFormFields.insertArrangedSubview(self.mOccupationField!, at: 2)
            
            self.mBiographyField = buildTextField(placeholder: "Biografia", icon: String.fontAwesomeIcon(name: .lock))
            svFormFields.insertArrangedSubview(self.mBiographyField!, at: 3)
            
            mBirthDateField?.delegate = self
            mSearchCityField?.delegate = self
            mOccupationField?.delegate = self
            mBiographyField?.delegate = self
            
            mSearchCityField?.restorationIdentifier = "searchCityField"
            svFormFields.alignment = .fill
            svFormFields.distribution = .fill
            svFormFields.axis = .vertical
            svFormFields.spacing = 24
        
            getUserDetails()
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
            textField.selectedLineHeight = 2.0
            
            return textField
    }
    
    private func saveUserData() {

        let name = mNameField.text
        let email = mEmailField.text
        let city = mUser.city
        let gender = mUser.gender
        let birthdate = mBirthDateField.text
        let occupation = mOccupationField.text
        let biography = mBiographyField.text
        
        /*if(name.isEmpty || email.isEmpty ||
            birthdate.isEmpty || occupation.isEmpty || biography.isEmpty
            || city.isNullOrEmpty() || gender.isNullOrEmpty() ) {

            //makeToast("Todos os campos devem ser preenchidos!")
            return
        }

        if(name.contains("@")) {
            //makeToast("Por favor preencha um nome válido!")
            return
        }

        if(!email.contains("@")) {
            //makeToast("Por favor preencha um e-mail válido!")
            return
        }

        if(birthdate.length < 10) {
            //makeToast("Preencha uma data de nascimento válida")
            return
        }

        mUser.name = name
        mUser.email = email
        mUser.description = biography
        mUser.birthdate = birthdate
        mUser.occupation = occupation

        btEditProfleSavaData.startAnimation()

        mDatabase.collection(mCollections.USERS)
            .document(mUser.id)
            .set(mUser.toMap())
            .addOnSuccessListener {
                makeToast("Dados salvos com sucesso!")
                btEditProfleSavaData.doneLoadingAnimation(
                    resources.getColor(com.balloondigital.egvapp.R.color.colorGreen),
                    Converters.drawableToBitmap(resources.getDrawable(com.balloondigital.egvapp.R.drawable.ic_check_grey_light))
                )

            }*/
    }

}

extension EditProfileVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.restorationIdentifier == "searchCityField" {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            
            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue))!
            autocompleteController.placeFields = fields
            
            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            filter.type = .address
            autocompleteController.autocompleteFilter = filter
            
            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)

        }
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