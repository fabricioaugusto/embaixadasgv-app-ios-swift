//
//  MenuCell.swift
//  EGVApp
//
//  Created by Fabricio on 12/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var mImgMenuIcon: UIImageView!
    @IBOutlet weak var mLbMenuText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func prepare(with menu: AppMenuItem) {
        mLbMenuText.text = menu.item_name
        mImgMenuIcon.image = menu.item_icon
    }
}
