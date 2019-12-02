//
//  ThoughtCell.swift
//  EGVApp
//
//  Created by Fabricio on 11/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FaveButton
import Kingfisher
import SwiftRichString

class ThoughtCell: UITableViewCell {
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbPostDate: UILabel!
    @IBOutlet weak var mLbPostDescription: UILabel!
    @IBOutlet weak var mLbLikesCount: UILabel!
    @IBOutlet weak var mLbCommentsCount: UILabel!
    @IBOutlet weak var mBtLike: FaveButton!
    
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

    @IBAction func onClickLikeBt(_ sender: FaveButton) {
        let postLiked = sender.isSelected
        sender.isEnabled = false
        if(postLiked) {
            let numLikes = post.post_likes+1
            post.post_likes = numLikes
            mLbLikesCount.text = "\(numLikes)"
            rootVC.setLikePost(post: self.post) { (bool) in
                sender.isEnabled = true
            }
            //rootVC.setLikePost(post: self.post)
        } else {
            let numLikes = post.post_likes-1
            post.post_likes = numLikes
            mLbLikesCount.text = "\(numLikes)"
            rootVC.setUnlikePost(post: self.post) { (bool) in
                sender.isEnabled = true
            }
            //rootVC.setUnlikePost(post: self.post)
        }
    }
    
    
    func prepare(with post: Post, postLikes: [PostLike]) {
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
        
        if(post.post_likes > 0) {
            mLbLikesCount.text = "\(post.post_likes)"
        } else {
            mLbLikesCount.text = ""
        }
        
        if(post.post_comments > 0) {
            mLbCommentsCount.text = "\(post.post_comments)"
        } else {
            mLbCommentsCount.text = ""
        }
        
        if postLikes.contains(where: { postLike in postLike.post_id == post.id }) {
            mBtLike.setSelected(selected: true, animated: false)
        } else {
            mBtLike.setSelected(selected: false, animated: false)
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
