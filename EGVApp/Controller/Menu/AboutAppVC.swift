//
//  AboutAppVC.swift
//  EGVApp
//
//  Created by Fabricio on 29/01/20.
//  Copyright © 2020 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AboutAppVC: UIViewController {

    @IBOutlet weak var mLbAppTitle: UILabel!
    @IBOutlet weak var mLbAppVersion: UILabel!
    @IBOutlet weak var mLbAppDescription: UILabel!
    @IBOutlet weak var mBtAppSite: UIButton!
    @IBOutlet weak var mLbAppDeveloperDescription: UILabel!
    @IBOutlet weak var mLbAppPartnerDescription: UILabel!
    @IBOutlet var mGroupBtSocial: [UIButton]!
    @IBOutlet weak var mBtDeveloperWhatsapp: UIButton!
    @IBOutlet weak var mBtDeveloperFacebook: UIButton!
    @IBOutlet weak var mBtDeveloperInstagram: UIButton!
    @IBOutlet weak var mBtDeveloperWebsite: UIButton!
    @IBOutlet weak var mBtDeveloperEmail: UIButton!
    @IBOutlet weak var mBtPartnerWhatsapp: UIButton!
    @IBOutlet weak var mBtPartnerFacebook: UIButton!
    @IBOutlet weak var mBtPartnerInstagram: UIButton!
    @IBOutlet weak var mBtPartnerWebsite: UIButton!
    @IBOutlet weak var mBtPartnerEmail: UIButton!
    private var mDatabase: Firestore!
    private var mDeveloperWhatsapp: String = ""
    private var mDeveloperFacebook: String = ""
    private var mDeveloperInstagram: String = ""
    private var mDeveloperWebsite: String = ""
    private var mDeveloperEmail: String = ""
    private var mPartnerWhatsapp: String = ""
    private var mPartnerFacebook: String = ""
    private var mPartnerInstagram: String = ""
    private var mPartnerWebsite: String = ""
    private var mPartnerEmail: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mDatabase = MyFirebase.sharedInstance.database()
        self.getAboutApp()
        
        for button in mGroupBtSocial {
            button.layer.cornerRadius = 20
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtWebsite(_ sender: UIButton) {
        let url = URL(string: "https://embaixadasgv.app")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func getAboutApp() {
        self.mDatabase.collection(MyFirebaseCollections.APP_CONTENT)
            .document("about_app")
            .getDocument(completion: { (documentSnapshot, error) in
                
                if let document = documentSnapshot {
                    if let documentData = document.data() {
                        
                        let app_name = documentData["app_name"] as? String ?? ""
                        self.mLbAppTitle.text = app_name
                        
                        let app_version = documentData["app_version"] as? Float ?? 0
                        self.mLbAppVersion.text = "Versão \(app_version)"
                        
                        let app_description = documentData["app_description"] as? String ?? ""
                        self.mLbAppDescription.text = app_description
                        
                        let app_developer_description = documentData["app_developer_description"] as? String ?? ""
                        self.mLbAppDeveloperDescription.text = app_developer_description
                        
                        let app_partner_description = documentData["app_partner_description"] as? String ?? ""
                        self.mLbAppPartnerDescription.text = app_partner_description
                        
                        let app_developer_whatsapp = documentData["app_developer_whatsapp"] as? String ?? ""
                        
                        if !app_developer_whatsapp.isEmpty {
                            self.mDeveloperWhatsapp = app_developer_whatsapp
                            self.mBtDeveloperWhatsapp.isHidden = false
                        }
                        
                        let app_developer_facebook = documentData["app_developer_facebook"] as? String ?? ""
                        
                        if !app_developer_facebook.isEmpty {
                            self.mDeveloperFacebook = app_developer_facebook
                            self.mBtDeveloperFacebook.isHidden = false
                        }
                        
                        let app_developer_instagram = documentData["app_developer_instagram"] as? String ?? ""
                        
                        if !app_developer_instagram.isEmpty {
                            self.mDeveloperInstagram = app_developer_instagram
                            self.mBtDeveloperInstagram.isHidden = false
                        }
                        
                        let app_developer_website = documentData["app_developer_website"] as? String ?? ""
                        
                        if !app_developer_website.isEmpty {
                            self.mDeveloperWebsite = app_developer_website
                            self.mBtDeveloperWebsite.isHidden = false
                        }
                        
                        let app_developer_email = documentData["app_developer_email"] as? String ?? ""
                        
                        if !app_developer_email.isEmpty {
                            self.mDeveloperEmail = app_developer_email
                            self.mBtDeveloperEmail.isHidden = false
                        }
                        
                        let app_partner_whatsapp = documentData["app_partner_whatsapp"] as? String ?? ""
                        
                        if !app_partner_whatsapp.isEmpty {
                            self.mPartnerWhatsapp = app_partner_whatsapp
                            self.mBtPartnerWhatsapp.isHidden = false
                        }
                        
                        let app_partner_facebook = documentData["app_partner_facebook"] as? String ?? ""
                        
                        if !app_partner_facebook.isEmpty {
                            self.mPartnerFacebook = app_partner_facebook
                            self.mBtPartnerFacebook.isHidden = false
                        }
                        
                        let app_partner_instagram = documentData["app_partner_instagram"] as? String ?? ""
                        
                        if !app_partner_instagram.isEmpty {
                            self.mPartnerInstagram = app_partner_instagram
                            self.mBtPartnerInstagram.isHidden = false
                        }
                        
                        let app_partner_website = documentData["app_partner_website"] as? String ?? ""
                        
                        if !app_partner_website.isEmpty {
                            self.mPartnerWebsite = app_partner_website
                            self.mBtPartnerWebsite.isHidden = false
                        }
                        
                        let app_partner_email = documentData["app_partner_email"] as? String ?? ""
                        
                        if !app_partner_email.isEmpty {
                            self.mPartnerEmail = app_partner_email
                            self.mBtPartnerEmail.isHidden = false
                        }
                    }
                }
                
            })
    }
    
    @IBAction func onClickBtDeveloperWhatsapp(_ sender: UIButton) {
        let url = URL(string: "https://wa.me/\(self.mDeveloperWhatsapp)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtDeveloperFacebook(_ sender: UIButton) {
        let url = URL(string: "https://facebook.com/\(mDeveloperFacebook)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtDeveloperInstagram(_ sender: UIButton) {
        let url = URL(string: "https://instagram.com/\(self.mDeveloperInstagram)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtDeveloperWebsite(_ sender: UIButton) {
        let url = URL(string: "\(self.mDeveloperWebsite)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtDeveloperEmail(_ sender: UIButton) {
        let url = URL(string: "mailto:\(self.mDeveloperEmail)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtPartnerWhatsapp(_ sender: UIButton) {
        let url = URL(string: "https://wa.me/\(self.mPartnerWhatsapp)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtPartnerFacebook(_ sender: UIButton) {
        let url = URL(string: "https://facebook.com/\(mDeveloperFacebook)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtPartnerInstagram(_ sender: UIButton) {
        let url = URL(string: "https://instagram.com/\(self.mDeveloperInstagram)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtPartnerWebsite(_ sender: Any) {
        let url = URL(string: "\(self.mDeveloperWebsite)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func onClickBtPartnerEmail(_ sender: UIButton) {
        let url = URL(string: "mailto:\(self.mPartnerEmail)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
