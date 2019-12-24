//
//  EditSocialNetworkingVC.swift
//  EGVApp
//
//  Created by Fabricio on 26/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

class EditSocialNetworkingVC: UIViewController {

    @IBOutlet weak var mWhatsappField: UITextField!
    @IBOutlet weak var mFacebookField: UITextField!
    @IBOutlet weak var mInstagramField: UITextField!
    @IBOutlet weak var mLinkedinField: UITextField!
    @IBOutlet weak var mTwitterField: UITextField!
    @IBOutlet weak var mBehanceField: UITextField!
    @IBOutlet weak var mGitHubField: UITextField!
    @IBOutlet weak var mYoutubeField: UITextField!
    @IBOutlet weak var mSiteField: UITextField!
    @IBOutlet var mGroupFields: [UIStackView]!
    
    var mUser: User!
    weak var mRootMenuTableVC: RootMenuTableVC!
    private var mDatabase: Firestore!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in mGroupFields {
            AppLayout.addLineToView(view: view, position: .LINE_POSITION_BOTTOM, color: AppColors.colorBorderGrey, width: 1)
        }
        
        mDatabase = MyFirebase.sharedInstance.database()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Registrando..."
        
        bindData()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtSaveData(_ sender: UIBarButtonItem) {
        self.saveUserData()
    }
    
    
    private func bindData() {
    
        if(mUser.whatsapp != nil) {
            mWhatsappField.text = mUser.whatsapp
        }
    
        if(mUser.facebook != nil) {
            mFacebookField.text = mUser.facebook
        }
    
        if(mUser.instagram != nil) {
            mInstagramField.text = mUser.instagram
        }
    
        if(mUser.twitter != nil) {
            mTwitterField.text = mUser.twitter
        }
    
        if(mUser.linkedin != nil) {
            mLinkedinField.text = mUser.linkedin
        }
    
        if(mUser.youtube != nil) {
            mYoutubeField.text = mUser.youtube
        }
    
        if(mUser.behance != nil) {
            mBehanceField.text = mUser.behance
        }
    
        if(mUser.github != nil) {
            mGitHubField.text = mUser.github
        }
    }
    
    private func saveUserData() {
    
        let whatsapp = mWhatsappField.text ?? ""
        let facebook = mFacebookField.text ?? ""
        let instagram = mInstagramField.text ?? ""
        let twitter = mTwitterField.text ?? ""
        let linkedin = mLinkedinField.text ?? ""
        let youtube = mYoutubeField.text ?? ""
        let behance = mBehanceField.text ?? ""
        let github = mGitHubField.text ?? ""
    
        if(whatsapp.contains("http") ||  whatsapp.contains("https")) {
            makeAlert(message: "")
            return
        }
    
        if(facebook.contains("http") ||  facebook.contains("https")) {
            makeAlert(message: "Coloque somente o nome de usuário do Facebook e não o endereço (link) do perfil")
            return
        }
    
        if(instagram.contains("http") ||  instagram.contains("https")) {
            makeAlert(message: "Coloque somente o nome de usuário do Instagram e não o endereço (link) do perfil")
            return
        }
    
        if(twitter.contains("http") ||  twitter.contains("https")) {
            makeAlert(message: "Coloque somente o nome de usuário do Twitter e não o endereço (link) do perfil")
            return
        }
    
        if(linkedin.contains("http") ||  linkedin.contains("https")) {
            makeAlert(message: "Coloque somente o nome de usuário do Linkedin e não o endereço (link) do perfil")
            return
        }
    
        if(youtube.contains("http") ||  youtube.contains("https")) {
            makeAlert(message: "Coloque somente o nome de usuário do Youtube e não o endereço (link) do perfil")
            return
        }
    
        if(behance.contains("http") ||  behance.contains("https")) {
            makeAlert(message: "Coloque somente o nome de usuário do Behance e não o endereço (link) do perfil")
            return
        }
    
        if(github.contains("http") ||  github.contains("https")) {
            makeAlert(message: "Coloque somente o nome de usuário do Github e não o endereço (link) do perfil")
            return
        }
    
        
        var socialProfiles: [String: Any] = [:]
    
        if(!whatsapp.isEmpty && whatsapp != mUser.whatsapp) {
            socialProfiles["whatsapp"] = whatsapp
        } else if(whatsapp.isEmpty && whatsapp != mUser.whatsapp) {
            socialProfiles["whatsapp"] = NSNull()
        }
    
        if(!facebook.isEmpty && facebook != mUser.facebook) {
            socialProfiles["facebook"] = facebook
        } else if(facebook.isEmpty && facebook != mUser.facebook) {
            socialProfiles["facebook"] = NSNull()
        }
    
        if(!instagram.isEmpty && instagram != mUser.instagram) {
            socialProfiles["instagram"] = instagram
        } else if(instagram.isEmpty && instagram != mUser.instagram) {
            socialProfiles["instagram"] = NSNull()
        }
    
        if(!twitter.isEmpty && twitter != mUser.twitter) {
            socialProfiles["twitter"] = twitter
        } else if(twitter.isEmpty && twitter != mUser.twitter) {
            socialProfiles["twitter"] = NSNull()
        }
    
        if(!linkedin.isEmpty && linkedin != mUser.linkedin) {
            socialProfiles["linkedin"] = linkedin
        } else  if(linkedin.isEmpty && linkedin != mUser.linkedin) {
            socialProfiles["linkedin"] = NSNull()
        }
    
        if(!youtube.isEmpty && youtube != mUser.youtube) {
            socialProfiles["youtube"] = youtube
        } else if(youtube.isEmpty && youtube != mUser.youtube) {
            socialProfiles["youtube"] = NSNull()
        }
    
        if(!behance.isEmpty && behance != mUser.behance) {
            socialProfiles["behance"] = behance
        } else if(behance.isEmpty && behance != mUser.behance) {
            socialProfiles["behance"] = NSNull()
        }
        
        if(!github.isEmpty && github != mUser.github) {
            socialProfiles["github"] = github
        } else if(github.isEmpty && github != mUser.github) {
            socialProfiles["github"] = NSNull()
        }
    
        self.mHud.show(in: self.view)
    
        self.mDatabase.collection(MyFirebaseCollections.USERS)
            .document(mUser.id)
            .updateData(socialProfiles, completion: { (error) in
                if let error = error {
                    
                } else {
                    self.mHud.dismiss()
                    self.mRootMenuTableVC.updateUserData()
                    self.makeAlert(message: "Dados salvos com sucesso")
                }
            })
        
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
