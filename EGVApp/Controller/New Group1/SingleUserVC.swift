//
//  SingleUserVC.swift
//  EGVApp
//
//  Created by Fabricio on 13/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import FontAwesome_swift

class SingleUserVC: UIViewController {
    
    @IBOutlet weak var mImgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbUserOccupation: UILabel!
    @IBOutlet weak var mLbUserEmbassy: UILabel!
    @IBOutlet weak var mLbUserCity: UILabel!
    @IBOutlet weak var mLbUserDescription: UILabel!
    @IBOutlet weak var mSvContainerCollection: UIStackView!
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var mSvConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var lbUserStatus: UILabel!
    @IBOutlet weak var identifierView: UIView!
    
    private var mDatabase: Firestore!
    private var mSocialNetworking: [[String: Any]] = []
    private var mUser: User!
    var mUserID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mDatabase = MyFirebase.sharedInstance.database()
        self.getUserDetails()
        // Do any additional setup after loading the view.
    }
    
    private func getUserDetails() {
        self.mDatabase.collection(MyFirebaseCollections.USERS)
        .document(mUserID)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    
                } else {
                    if let user = documentSnapshot.flatMap({
                        $0.data().flatMap({ (data) in
                            return User(dictionary: data)
                        })
                    }) {
                        self.mUser = user
                        
                        let name_array = self.mUser.name.components(separatedBy: " ")
                        if(name_array.count > 0) {
                            self.title = name_array[0]
                        }
                        
                        self.bindData()
                    } else {
                        print("Documento not exists")
                    }
                }
        }
    }
    
    private func bindData() {
        
        mLbUserName.text = self.mUser.name
        mLbUserOccupation.text = self.mUser.occupation
        mLbUserEmbassy.text = self.mUser.embassy?.name
        mLbUserCity.text = self.mUser.city
        mLbUserDescription.text = self.mUser.description
        
        lbUserStatus.text = "Membro"
        identifierView.layer.cornerRadius = 12
        identifierView.layer.masksToBounds = true
        identifierView.layer.backgroundColor = AppColors.colorMember.cgColor
        
        if(self.mUser.leader) {
            lbUserStatus.text = "Líder"
            identifierView.backgroundColor = AppColors.colorLeader
        }
        
        if(self.mUser.sponsor) {
            if(self.mUser.gender == "female") {
                lbUserStatus.text = "Madrinha"
            } else {
                lbUserStatus.text = "Padrinho"
            }
            identifierView.backgroundColor = AppColors.colorSponsor
        }
        
        if(self.mUser.committee_leader) {
            lbUserStatus.text = "Líder de Comitê"
            identifierView.backgroundColor = AppColors.colorCommitteeLeader
        }
        
        if(mUser.influencer) {
            if(mUser.gender == "female") {
                lbUserStatus.text = "Influenciadora"
            } else {
                lbUserStatus.text = "Influenciador"
            }
            identifierView.backgroundColor = AppColors.colorInfluencer
        }
        
        if(mUser.counselor) {
            if(mUser.gender == "female") {
                lbUserStatus.text = "Conselheira"
            } else {
                lbUserStatus.text = "Conselheiro"
            }
            identifierView.backgroundColor = AppColors.colorCounselor
        }
        
        mImgUserProfile.layer.cornerRadius = 80
        mImgUserProfile.layer.masksToBounds = true
        
        mImgUserProfile.kf.indicatorType = .activity
        if let profile_img = mUser.profile_img {
            
            mImgUserProfile.layer.borderWidth = 5.0
            mImgUserProfile.layer.borderColor = AppColors.colorLightGrey.cgColor
            
            let url = URL(string: profile_img)
            mImgUserProfile.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        }
        
        if let facebook = self.mUser.facebook {
            let social: [String: Any] = [
                "name": "facebook",
                "url": "https://www.facebook.com/\(facebook)",
                "icon": String.fontAwesomeIcon(name: .facebook),
                "backgroundColor": UIColor(red: 41/255, green: 72/255, blue: 125/255, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let twitter = self.mUser.twitter {
            let social: [String: Any] = [
                "name": "twitter",
                "url": "https://twitter.com/\(twitter)",
                "icon": String.fontAwesomeIcon(name: .twitter),
                "backgroundColor": UIColor(red: 8/255, green: 160/255, blue: 233/255, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let instagram = self.mUser.instagram {
            let social: [String: Any] = [
                "name": "instagram",
                "url": "https://www.instagram.com/\(instagram)",
                "icon": String.fontAwesomeIcon(name: .instagram),
                "backgroundColor": UIColor(red: 251/255, green: 57/255, blue: 88/255, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let linkedin = self.mUser.linkedin {
            let social: [String: Any] = [
                "name": "linkedin",
                "url": "https://www.linkedin.com/in/\(linkedin)",
                "icon": String.fontAwesomeIcon(name: .linkedin),
                "backgroundColor": UIColor(red: 0/255, green: 119/255, blue: 181/255, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let whatsapp = self.mUser.whatsapp {
            let social: [String: Any] = [
                "name": "whatsapp",
                "url": "https://wa.me/\(whatsapp)",
                "icon": String.fontAwesomeIcon(name: .whatsapp),
                "backgroundColor": UIColor(red: 18/255, green: 140/255, blue: 126/255, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let youtube = self.mUser.youtube {
            let social: [String: Any] = [
                "name": "youtube",
                "url": "\(youtube)",
                "icon": String.fontAwesomeIcon(name: .youtube),
                "backgroundColor": UIColor(red: 230/255, green: 33/255, blue: 23/255, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let behance = self.mUser.behance {
            let social: [String: Any] = [
                "name": "behance",
                "url": "https://www.behance.net/\(behance)",
                "icon": String.fontAwesomeIcon(name: .behance),
                "backgroundColor": UIColor(red: 5/255, green: 62/255, blue: 255/255, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let github = self.mUser.github {
            let social: [String: Any] = [
                "name": "github",
                "url": "https://github.com/\(github)",
                "icon": String.fontAwesomeIcon(name: .github),
                "backgroundColor": UIColor(red: 33, green: 31, blue: 31, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        if let website = self.mUser.website {
            let social: [String: Any] = [
                "name": "website",
                "url": website,
                "icon": String.fontAwesomeIcon(name: .globeAmericas),
                "backgroundColor": UIColor(red: 46, green: 119, blue: 187, alpha: 1)
            ]
            self.mSocialNetworking.append(social)
        }
        
        
        if(mSocialNetworking.count > 0) {
            mCollectionView.isHidden = false
            mSvConstraintBottom.constant = 24
            DispatchQueue.main.async {
                self.mCollectionView.reloadData()
            }
        }
        
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

extension SingleUserVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mSocialNetworking.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "socialButtonCollectionCell", for: indexPath) as! SocialButtonCollectionCell
        cell.prepare(with: mSocialNetworking[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let snName = mSocialNetworking[indexPath.row]["name"] as! String
        
        if(snName == "whatsapp") {
            
            if var whatsapp = self.mUser.whatsapp {
                whatsapp = whatsapp.replacingOccurrences(of: " ", with: "")
                whatsapp = whatsapp.replacingOccurrences(of: "+", with: "")
                whatsapp = whatsapp.replacingOccurrences(of: "(", with: "")
                whatsapp = whatsapp.replacingOccurrences(of: ")", with: "")
                whatsapp = whatsapp.replacingOccurrences(of: "-", with: "")
                
                if(whatsapp.contains("+")) {
                    whatsapp = whatsapp.replacingOccurrences(of: "+", with: "")
                    let url = URL(string: "https://wa.me/\(whatsapp)")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    let url = URL(string: "https://wa.me/55\(whatsapp)")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else {
            let url = URL(string: mSocialNetworking[indexPath.row]["url"] as! String)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let screenSize: CGRect = UIScreen.main.bounds
        let totalCellWidth = 40 * mSocialNetworking.count
        let totalSpacingWidth = 5 * (mSocialNetworking.count - 1)
        
        let leftInset = (screenSize.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
}
