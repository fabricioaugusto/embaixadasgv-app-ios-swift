//
//  ManageEventCell.swift
//  EGVApp
//
//  Created by Fabricio on 17/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class ManageEventCell: UITableViewCell {

    
    @IBOutlet weak var mImgEventCover: UIImageView!
    @IBOutlet weak var mLbEventAbbrMonth: UILabel!
    @IBOutlet weak var mLbEventDay: UILabel!
    @IBOutlet weak var mLbEventTime: UILabel!
    @IBOutlet weak var mLbEventTheme: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with event: Event) {
        
        if let stamp = event.date {
            let date = stamp.dateValue()
            print("egvapplogevent", date)
            let formattedDate = FormatDate().dateToString(date: date)
            mLbEventDay.text = formattedDate["day"]
            mLbEventAbbrMonth.text = formattedDate["month"]?.uppercased()
            mLbEventTime.text = "\(String(describing: formattedDate["weekday"]!)) às \(String(describing: formattedDate["time"]!))".uppercased()
        }
        
        mLbEventTheme.text = event.theme
        
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
        } else {
            mImgEventCover.image = UIImage(named: "event_default_cover")
        }
    }

}

