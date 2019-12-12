//
//  SingleArticleCell.swift
//  EGVApp
//
//  Created by Fabricio on 23/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class SingleArticleCell: UITableViewCell {

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbPostDate: UILabel!
    @IBOutlet weak var mImgPost: UIImageView!
    @IBOutlet weak var mLbPostDescription: UITextView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var mLbLikesCount: UIButton!
    @IBOutlet weak var mLbCommentsCount: UILabel!
    @IBOutlet weak var mLbPostTitle: UILabel!
    
    weak var rootVC: SinglePostVC!
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickBtStartSingleUser(_ sender: Any) {
        self.rootVC.startSingleUserVC()
    }
    
    @IBAction func onClickBtListLikes(_ sender: UIButton) {
        self.rootVC.startListLikesVC()
    }
    
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
    
    func prepare(with post: Post) {
        let user: BasicUser = post.user
        
        AppLayout.addLineToView(view: baseView, position: .LINE_POSITION_BOTTOM, color: AppColors.colorBorderGrey, width: 1)
        
        mLbPostTitle.text = post.title
        mLbUserName.text = post.user.name
        
        if let stamp = post.date {
            let date = stamp.dateValue()
            let formattedDate = FormatDate().dateToString(date: date)
            mLbPostDate.text = "\(String(describing: formattedDate["date"]!)) às \(String(describing: formattedDate["time"]!))"
        }
        
        let bodyHTML = "<span style='font-family: \"-apple-system\", \"HelveticaNeue\" ; font-size:16;  color:#4D4D4F'>\(post.text!)</span>"
        if let htmldata = bodyHTML.data(using: String.Encoding.isoLatin1), let attributedString = try? NSAttributedString(data: htmldata, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            mLbPostDescription.attributedText = attributedString
        }
        
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
