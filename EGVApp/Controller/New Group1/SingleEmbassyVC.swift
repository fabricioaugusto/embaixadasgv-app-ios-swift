//
//  SingleEmbassyVC.swift
//  EGVApp
//
//  Created by Fabricio on 13/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

class SingleEmbassyVC: UIViewController {
    
    
    
    @IBOutlet weak var mLbEmbassyName: UILabel!
    @IBOutlet weak var mLbEmbassyCity: UILabel!
    @IBOutlet weak var mBtEmbassyPhone: UIButton!
    @IBOutlet weak var mBtEmbassyEmail: UIButton!
    @IBOutlet weak var mBtEmbassyAgenda: UIButton!
    @IBOutlet weak var mBtEmbassyMembers: UIButton!
    @IBOutlet weak var mImgEmbassyLeaderPhoto: UIImageView!
    @IBOutlet weak var mLbEmbassyLeaderName: UILabel!
    @IBOutlet weak var mEmbassyLeaderOccupation: UILabel!
    @IBOutlet weak var mEmbassyPhoto1: UIImageView!
    @IBOutlet weak var mEmbassyPhoto2: UIImageView!
    @IBOutlet weak var mEmbassyPhoto3: UIImageView!
    @IBOutlet weak var mConstraintContainerPhotos: NSLayoutConstraint!
    
    @IBOutlet var mGroupViews: [UIView]!
    @IBOutlet var mGroupButtons: [UIButton]!
    
    var mUser: User!
    var mEmbassyID: String!
    var mDatabase: Firestore!
    var mEmbassyPhotoList: [EmbassyPhoto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for view in mGroupViews {
            view.layer.cornerRadius = 5
            view.layer.borderColor = AppColors.colorBorderGrey.cgColor
            view.layer.borderWidth = 1
        }
        
        for button in mGroupButtons {
            button.layer.cornerRadius = 20
            button.layer.masksToBounds = true
        }
        
        mDatabase = MyFirebase.sharedInstance.database()
        getEmbassyDetails()
        // Do any additional setup after loading the view.
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
                        self.bindData(embassy: embassy)
                        self.getEmbassyPhotos()
                    }
                }
        }
    }
    
    private func getEmbassyPhotos() {
        mDatabase.collection(MyFirebaseCollections.EMBASSY_PHOTOS)
        .whereField("embassy_id", isEqualTo: mEmbassyID ?? "")
        .limit(to: 3)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    
                } else {
                    if let query = querySnapshot {
                        
                        if(query.documents.count > 0) {
                            for document in query.documents {
                                if let embassyPhoto = EmbassyPhoto(dictionary: document.data()) {
                                    self.mEmbassyPhotoList.append(embassyPhoto)
                                }
                            }
                            self.bindPhotos()
                        } else {
                            self.mConstraintContainerPhotos.constant = 5.0
                        }
                        
                    }
                }
        }
    }
    
    private func bindData(embassy: Embassy) {
        
        mImgEmbassyLeaderPhoto.layer.cornerRadius = 35
        mImgEmbassyLeaderPhoto.layer.masksToBounds = true
        
        mImgEmbassyLeaderPhoto.kf.indicatorType = .activity
        
        if let profile_img = embassy.leader?.profile_img {
            let url = URL(string: profile_img)
            mImgEmbassyLeaderPhoto.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        }
        
        mLbEmbassyName.text = embassy.name
        mLbEmbassyCity.text = "\(embassy.city) - \(embassy.state_short)"
        
        mLbEmbassyLeaderName.text = embassy.leader?.name
        mEmbassyLeaderOccupation.text = embassy.leader?.occupation
    }
    
    private func bindPhotos() {
        let url1 = URL(string: mEmbassyPhotoList[0].picture)
        self.mEmbassyPhoto1.kf.setImage(
            with: url1,
            placeholder: UIImage(named: "grey_circle"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        if(mEmbassyPhotoList.count > 1) {
            let url2 = URL(string: mEmbassyPhotoList[1].picture)
            self.mEmbassyPhoto2.kf.setImage(
                with: url2,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        }
        
        if(mEmbassyPhotoList.count > 2) {
            let url3 = URL(string: mEmbassyPhotoList[2].picture)
            self.mEmbassyPhoto2.kf.setImage(
                with: url3,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
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
