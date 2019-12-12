//
//  ArticleCell.swift
//  EGVApp
//
//  Created by Fabricio on 11/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FaveButton
import Kingfisher

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var mLbUserName: UILabel!
    @IBOutlet weak var mLbPostDate: UILabel!
    @IBOutlet weak var mImgPost: UIImageView!
    @IBOutlet weak var mLbPostDescription: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var mLbLikesCount: UILabel!
    @IBOutlet weak var mLbCommentsCount: UILabel!
    @IBOutlet weak var mBtLike: FaveButton!
    @IBOutlet weak var mLbPostTitle: UILabel!
    
    
    weak var rootVC: RootPostsTableVC!
    var post: Post!
    var mUser: User!
    var mIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickBtStartSingleUser(_ sender: Any) {
        self.rootVC.startSingleUserVC(userId: post.user_id)
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
    
    @IBAction func onClickOptionsBt(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Seleciona uma opção", message: "O que você deseja fazer?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Denunciar", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
        }))
        if mUser.id == post.user_id {
            alert.addAction(UIAlertAction(title: "Deletar", style: .destructive , handler:{ (UIAlertAction)in
                self.alertDeletePost()
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.rootVC.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func alertDeletePost() {
        let alert = UIAlertController(title: "Excluir Publicação", message: "Tem certeza que deseja excluir esta publicação?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sim, tenho certeza", style: UIAlertAction.Style.destructive, handler: { (alertAction) in
            self.rootVC.deletePost(post: self.post, index: self.mIndex)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        self.rootVC.present(alert, animated: true, completion: nil)
    }
    
    func prepare(with post: Post, postLikes: [PostLike]) {
        let user: BasicUser = post.user
        
        mLbPostTitle.text = post.title
        mLbUserName.text = post.user.name
        
        if let stamp = post.date {
            let date = stamp.dateValue()
            let formattedDate = FormatDate().dateToString(date: date)
            mLbPostDate.text = "\(String(describing: formattedDate["date"]!)) às \(String(describing: formattedDate["time"]!))"
        }
        
        let bodyHTML = "<span style='font-family: \"-apple-system\", \"HelveticaNeue\" ; font-size:14;  color:#4D4D4F'>\(post.text!)</span>"
        
        if let htmldata = bodyHTML.data(using: String.Encoding.isoLatin1), let attributedString = try? NSAttributedString(data: htmldata, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            mLbPostDescription.attributedText = attributedString
            mLbPostDescription.font = .systemFont(ofSize: 14.0)
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
