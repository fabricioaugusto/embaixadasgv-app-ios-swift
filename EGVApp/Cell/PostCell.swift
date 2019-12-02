//
//  PostCell.swift
//  EGVApp
//
//  Created by Fabricio on 09/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher
import FaveButton

class PostCell: UITableViewCell {

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbPostDate: UILabel!
    @IBOutlet weak var mImgPost: UIImageView!
    @IBOutlet weak var mLbPostDescription: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var svLikeContainer: UIStackView!
    @IBOutlet weak var mLbLikesCount: UILabel!
    @IBOutlet weak var mLbCommentsCount: UILabel!
    @IBOutlet weak var mBtLike: FaveButton!
    
    weak var rootVC: RootPostsTableVC!
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // constraint
    var aspectConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                mImgPost.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                mImgPost.addConstraint(aspectConstraint!)
            }
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
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
        
        if post.type == "picture" {
            
        }
        
        mLbUserName.text = post.user.name
        
        if let stamp = post.date {
            let date = stamp.dateValue()
            let formattedDate = FormatDate().dateToString(date: date)
            mLbPostDate.text = "\(String(describing: formattedDate["date"]!)) às \(String(describing: formattedDate["time"]!))"
        }
        
        mLbPostDescription.text = post.text!
        
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
        
        if let post_picture = post.picture {
            
            /*let url = URL(string: post_picture)
            mImgPost.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])*/
            
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWith = screenSize.width
            
            let url = URL(string: post_picture)
            
            if url != nil {
                
                let imageRatio = CGFloat(Float(post.picture_width) / Float(post.picture_height))
                
                let constraint = NSLayoutConstraint(
                    item: self.mImgPost,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: self.mImgPost,
                    attribute: .height,
                    multiplier: imageRatio,
                    constant: 0.0
                )
                
                constraint.priority = UILayoutPriority(999)
                aspectConstraint = constraint
                
                // kf
                OperationQueue.main.addOperation {
                    self.mImgPost.kf.setImage(
                        with: url,
                        placeholder: nil,
                        options: [.transition(.fade(0.3))],
                        progressBlock: nil,
                        completionHandler: { _ in
                    })
                }
            
            }
            
        }
        
    }

}

extension String {
    
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 18.0)! ]
            
            return try NSMutableAttributedString(data: data,
                                                 options: [.documentType: NSMutableAttributedString.DocumentType.html,
                                                           .characterEncoding: String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    
}


