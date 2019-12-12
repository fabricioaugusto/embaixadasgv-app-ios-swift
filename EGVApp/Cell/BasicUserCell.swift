//
//  BasicUserCell.swift
//  EGVApp
//
//  Created by Fabricio on 10/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class BasicUserCell: UITableViewCell {

    @IBOutlet weak var imgProfileUser: UIImageView!
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var lbUserOccupation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // Configure the view for the selected state
    }
    
    func prepare(with user: BasicUser) {
        
        self.lbUserName.text = user.name
        self.lbUserOccupation.text = user.occupation
        
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
