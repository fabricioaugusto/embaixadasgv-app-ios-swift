//
//  NotificationCell.swift
//  EGVApp
//
//  Created by Fabricio on 19/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var mImgNotification: UIImageView!
    @IBOutlet weak var mLbNotificationTitle: UILabel!
    @IBOutlet weak var mLbNotificationDate: UILabel!
    @IBOutlet weak var mViewCellContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with notification: Notification) {
        
        if let stamp = notification.created_at {
            let date = stamp.dateValue()
            let formattedDate = FormatDate().dateToString(date: date)
            mLbNotificationDate.text = "\(String(describing: formattedDate["date"]!)) às \(String(describing: formattedDate["time"]!))"
        }
        
        let bodyHTML = "<span style='font-family: \"-apple-system\", \"HelveticaNeue\" ; font-size:16;  color:#4D4D4F'; padding: 0; margin: 0;>\(notification.title)</span>"
        if let htmldata = bodyHTML.data(using: String.Encoding.isoLatin1), let attributedString = try? NSAttributedString(data: htmldata, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            mLbNotificationTitle.attributedText = attributedString
        }
        
        if(!notification.read) {
            mViewCellContainer.backgroundColor = UIColor(red: 51/255, green: 101/255, blue: 138/255, alpha: 0.1)
        }

        
        mImgNotification.layer.cornerRadius = 20
        mImgNotification.layer.masksToBounds = true

        if !notification.picture.isEmpty {
            let url = URL(string: notification.picture)
            mImgNotification.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        } else {
            let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/assets%2Fimages%2Fbg_egv_logo.png?alt=media&token=90971d90-b517-47c5-a3c8-cede129cba3e")
            mImgNotification.kf.setImage(
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
