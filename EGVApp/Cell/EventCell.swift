//
//  EventCell.swift
//  EGVApp
//
//  Created by Fabricio on 12/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher

class EventCell: UITableViewCell {

    
    @IBOutlet weak var mImgEventCover: UIImageView!
    @IBOutlet weak var mLbEventAbbrMonth: UILabel!
    @IBOutlet weak var mLbEventDay: UILabel!
    @IBOutlet weak var mLbEventTime: UILabel!
    @IBOutlet weak var mLbEventTheme: UILabel!
    @IBOutlet weak var mLbEventEmbassy: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // Configure the view for the selected state
    }
    
    func prepare(with event: Event) {
        
        mLbEventTheme.text = event.theme
        mLbEventEmbassy.text = (event.embassy?.name ?? "")+" - "+(event.city ?? "")+", "+event.state
        mLbEventAbbrMonth.text = "Nov"
        mLbEventDay.text = "07"
        mLbEventTime.text = "${dateStr.weekday} às ${dateStr.hours}:${dateStr.minutes}"

        
        if let cover_img = event.cover_img {
            let url = URL(string: cover_img)
            mImgEventCover.kf.setImage(
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
