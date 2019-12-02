//
//  SingleThoughtCell.swift
//  EGVApp
//
//  Created by Fabricio on 23/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class SingleThoughtCell: UITableViewCell {

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbPostDate: UILabel!
    @IBOutlet weak var mLbPostDescription: UILabel!
    @IBOutlet weak var mLbLikesCount: UIButton!
    @IBOutlet weak var mLbCommentsCount: UILabel!
    @IBOutlet weak var baseView: UIView!
    
    weak var rootVC: RootPostsTableVC!
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with post: Post) {
        
        AppLayout.addLineToView(view: baseView, position: .LINE_POSITION_BOTTOM, color: AppColors.colorBorderGrey, width: 1)
        
        let user: BasicUser = post.user
        
        mLbUserName.text = post.user.name
        
        if let stamp = post.date {
            let date = stamp.dateValue()
            let formattedDate = FormatDate().dateToString(date: date)
            mLbPostDate.text = "\(String(describing: formattedDate["date"]!)) às \(String(describing: formattedDate["time"]!))"
        }
        
        let bodyHTML = "<span style='font-family: \"-apple-system\", \"HelveticaNeue\" ; font-size:24;  color:#4D4D4F'; padding: 0; margin: 0;>\(post.text!)</span>"
        let data = Data(bodyHTML.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            mLbPostDescription.attributedText = attributedString
        }
        
        mLbPostDescription.font = .systemFont(ofSize: 24.0)
        
        if(post.post_likes > 0) {
            if(post.post_likes == 1) {
                mLbLikesCount.text("\(post.post_likes) curtida")
            } else {
                mLbLikesCount.text("\(post.post_likes) curtidas")
            }
        } else {
            mLbLikesCount.isHidden = true
            mLbLikesCount.text("")
        }
        
        if(post.post_comments > 0) {
            if(post.post_comments == 1) {
                mLbCommentsCount.text = "\(post.post_comments) comentário"
            } else {
                mLbCommentsCount.text = "\(post.post_comments) comentários"
            }
        } else {
            mLbCommentsCount.isHidden = true
            mLbCommentsCount.text = ""
        }
        
        
        imgUserProfile.layer.cornerRadius = 20
        imgUserProfile.layer.masksToBounds = true
        
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
        
    }
    
}


