//
//  CompleteRegisterVC.swift
//  EGVApp
//
//  Created by Fabricio on 18/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseAuth
import FirebaseFirestore
import GooglePlaces

class CompleteRegisterVC: UIViewController {

    
    @IBOutlet weak var svFormFields: UIStackView!
    
    var mInvite: Invite!
    private var mAuth: Auth!
    private var mDatabase: Firestore!
    private var mBirthDateField: SkyFloatingLabelTextField?
    private var mSearchCityField: SkyFloatingLabelTextField?
    private var mOccupationField: SkyFloatingLabelTextField?
    private var mBiographyField: SkyFloatingLabelTextField?
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        // Add the search bar to the right of the nav bar,
        // use a popover to display the results.
        // Set an explicit size as we don't want to use the entire nav bar.
        searchController?.searchBar.frame = (CGRect(x: 0, y: 0, width: 250.0, height: 44.0))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: (searchController?.searchBar)!)

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        // Keep the navigation bar visible.
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.modalPresentationStyle = .popover
        
        // Do any additional setup after loading the view.
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
}

extension CompleteRegisterVC: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    // Do something with the selected place.
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place attributions: \(place.attributions)")
  }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}


extension CompleteRegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
