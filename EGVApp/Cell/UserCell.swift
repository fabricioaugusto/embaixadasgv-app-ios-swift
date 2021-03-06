//
//  UserCell.swift
//  EGVApp
//
//  Created by Fabricio on 09/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher

class UserCell: UITableViewCell {
    
    @IBOutlet weak var imgProfileUser: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbUserOccupation: UILabel!
    @IBOutlet weak var lbUserStatus: InsetLabel!
    @IBOutlet weak var identifierView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with user: User) {
        
        self.lbUserName.text = user.name
        self.lbUserOccupation.text = user.occupation
        
        
        lbUserStatus.text = "Membro"
        identifierView.layer.cornerRadius = 12
        identifierView.layer.masksToBounds = true
        identifierView.layer.backgroundColor = AppColors.colorMember.cgColor
        
        if(user.leader) {
            lbUserStatus.text = "Líder"
            identifierView.backgroundColor = AppColors.colorLeader
        }
        
        if(user.sponsor) {
            if(user.gender == "female") {
                lbUserStatus.text = "Madrinha"
            } else {
                lbUserStatus.text = "Padrinho"
            }
            identifierView.backgroundColor = AppColors.colorSponsor
        }
        
        if(user.committee_leader) {
            lbUserStatus.text = "Líder de Comitê"
            identifierView.backgroundColor = AppColors.colorCommitteeLeader
        }
        
        
        if(user.influencer) {
            if(user.gender == "female") {
                lbUserStatus.text = "Influenciadora"
            } else {
                lbUserStatus.text = "Influenciador"
            }
            identifierView.backgroundColor = AppColors.colorInfluencer
        }
        
        if(user.counselor) {
            if(user.gender == "female") {
                lbUserStatus.text = "Conselheira"
            } else {
                lbUserStatus.text = "Conselheiro"
            }
            identifierView.backgroundColor = AppColors.colorCounselor
        }
        
        imgProfileUser.layer.cornerRadius = 30
        imgProfileUser.layer.masksToBounds = true
        
        imgProfileUser.kf.indicatorType = .activity
        if let profile_img = user.profile_img {
            let url = URL(string: profile_img)
            imgProfileUser.kf.setImage(
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

class InsetLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 16.0
    @IBInspectable var rightInset: CGFloat = 16.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
}
