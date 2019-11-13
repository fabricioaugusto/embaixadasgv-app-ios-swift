//
//  UserProfileCell.swift
//  EGVApp
//
//  Created by Fabricio on 12/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher

class UserProfileCell: UITableViewCell {

    @IBOutlet weak var mImgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with user: User) {
        
        mLbUserName.text = user.name
        
        mImgUserProfile.layer.cornerRadius = 25
        mImgUserProfile.layer.masksToBounds = true
        
        mImgUserProfile.kf.indicatorType = .activity
        if let profile_img = user.profile_img {
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

}
