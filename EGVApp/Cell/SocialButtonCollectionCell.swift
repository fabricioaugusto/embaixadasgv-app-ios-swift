//
//  SocialButtonCollectionCell.swift
//  EGVApp
//
//  Created by Fabricio on 29/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class SocialButtonCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mBtSocial: UIButton!
    
    
    func prepare(with social: [String:Any]) {
        
        mBtSocial.backgroundColor = social["backgroundColor"] as? UIColor ?? AppColors.colorLink
        mBtSocial.layer.cornerRadius = 22.5
        mBtSocial.layer.masksToBounds = true
        mBtSocial.text(social["icon"] as! String)
        mBtSocial.tintColor = AppColors.colorWhite
        mBtSocial.titleLabel?.textColor = AppColors.colorWhite
        mBtSocial.titleLabel?.font = UIFont.fontAwesome(ofSize: 22, style: .brands)
    }
    
}
