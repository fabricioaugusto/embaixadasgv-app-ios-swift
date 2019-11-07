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

class LoginVC: UIViewController {

    
    @IBOutlet weak var mSVContainerLogin: UIStackView!
    @IBOutlet weak var mLoginBT: UIButton!
    @IBOutlet weak var mBtForgotPass: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFields()
        // Do any additional setup after loading the view.
    }
    
    
    private func addFields() {
        
        let emailField = buildTextField(placeholder: "E-mail", icon: String.fontAwesomeIcon(name: .envelope))
        mSVContainerLogin.insertArrangedSubview(emailField, at: 0)
        
        let passwordField = buildTextField(placeholder: "Senha", icon: String.fontAwesomeIcon(name: .lock))
        mSVContainerLogin.insertArrangedSubview(passwordField, at: 1)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
