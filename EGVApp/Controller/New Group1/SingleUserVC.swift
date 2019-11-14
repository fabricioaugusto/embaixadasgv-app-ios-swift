//
//  SingleUserVC.swift
//  EGVApp
//
//  Created by Fabricio on 13/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher

class SingleUserVC: UIViewController {
    
    @IBOutlet weak var mImgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbUserOccupation: UILabel!
    @IBOutlet weak var mLbUserEmbassy: UILabel!
    @IBOutlet weak var mLbUserCity: UILabel!
    @IBOutlet weak var mLbUserDescription: UILabel!

    
    var mUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
        // Do any additional setup after loading the view.
    }
    
    private func bindData() {
        
        mLbUserName.text = self.mUser.name
        mLbUserOccupation.text = self.mUser.occupation
        mLbUserEmbassy.text = self.mUser.embassy.name
        mLbUserCity.text = self.mUser.city
        mLbUserDescription.text = self.mUser.description
        
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
