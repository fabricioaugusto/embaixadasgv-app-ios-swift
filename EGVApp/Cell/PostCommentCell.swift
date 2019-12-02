//
//  PostCommentCell.swift
//  EGVApp
//
//  Created by Fabricio on 23/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher

class PostCommentCell: UITableViewCell {

    @IBOutlet weak var mImgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbCommentDate: UILabel!
    @IBOutlet weak var mLbCommentText: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with comment: PostComment) {
        
        mLbUserName.text = comment.user.name
        mLbCommentText.text = comment.text
        
        
        
        mImgUserProfile.layer.cornerRadius = 12.5
        mImgUserProfile.layer.masksToBounds = true
        
        mImgUserProfile.kf.indicatorType = .activity
        if let profile_img = comment.user.profile_img {
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
