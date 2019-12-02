//
//  EmbassyCell.swift
//  EGVApp
//
//  Created by Fabricio on 27/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class EmbassyCell: UITableViewCell {

    @IBOutlet weak var mLbEmbassyName: UILabel!
    @IBOutlet weak var mLbEmbassyCity: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with embassy:Embassy) {
        mLbEmbassyName.text = embassy.name
        mLbEmbassyCity.text = "\(embassy.city) - \(embassy.state_short)"
    }

}
