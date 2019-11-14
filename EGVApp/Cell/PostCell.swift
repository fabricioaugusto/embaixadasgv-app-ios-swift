//
//  PostCell.swift
//  EGVApp
//
//  Created by Fabricio on 09/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher

class PostCell: UITableViewCell {

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
    
    func prepare(with post: Post) {
        let user: BasicUser = post.user

        if post.type == "picture" {
            
        }
        
        mLbUserName.text = post.user.name
        mLbPostDate.text = "10/11/2019"
        mLbPostDescription.attributedText = post.text?.htmlToAttributedString
        mLbPostDescription.font = .systemFont(ofSize: 16.0)
        
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
                let postimg_size = PostCell.sizeOfImageAt(url: url!)
                let imageRatio = CGFloat(Float(postimg_size?.width ?? 0) / Float(postimg_size?.height ?? 0))
                
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
    
    static func sizeOfImageAt(url: URL) -> CGSize? {
        // with CGImageSource we avoid loading the whole image into memory
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }
        
        if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
            let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
            return CGSize(width: width, height: height)
        } else {
            return nil
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
