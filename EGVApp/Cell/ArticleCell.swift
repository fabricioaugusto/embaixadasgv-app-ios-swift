//
//  ArticleCell.swift
//  EGVApp
//
//  Created by Fabricio on 11/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbPostDate: UILabel!
    @IBOutlet weak var mImgPost: UIImageView!
    @IBOutlet weak var mLbPostDescription: UILabel!
    @IBOutlet weak var baseView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with post: Post) {
        let user: BasicUser = post.user
        
        
        mLbUserName.text = post.user.name
        mLbPostDate.text = "10/11/2019"
        mLbPostDescription.attributedText = post.text?.htmlToAttributedString
        
        
        imgUserProfile.kf.indicatorType = .activity
        if let profile_img = user.profile_img {
            let url = URL(string: profile_img)
            imgUserProfile.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        }
        
        if let post_picture = post.picture {
            
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWith = screenSize.width
            
            let url = URL(string: post_picture)
            
            if url != nil {
                let imageRatio = CGFloat(Float(post.picture_width) / Float(post.picture_height))
                let height = screenWith / imageRatio
                
                let heightConstraint = NSLayoutConstraint(item: mImgPost!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
                
                baseView.addConstraint(heightConstraint)
            }
            
            mImgPost.kf.indicatorType = .activity
            mImgPost.kf.setImage(
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
