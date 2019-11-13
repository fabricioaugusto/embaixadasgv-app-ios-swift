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
        
        if let stamp = event.date {
            let date = stamp.dateValue()
            print("egvapplogevent", date)
            let formattedDate = formatDate(date: date)
            mLbEventDay.text = formattedDate["day"]
            mLbEventAbbrMonth.text = formattedDate["month"]?.uppercased()
            mLbEventTime.text = "\(String(describing: formattedDate["weekday"]!)) às \(String(describing: formattedDate["time"]!))".uppercased()
        }
        
        mLbEventTheme.text = event.theme
        mLbEventEmbassy.text = "\(String(describing: event.embassy?.name ?? "")) - \(String(describing: event.city ?? "")), \(String(describing: event.state_short ?? ""))"
        
        
        

        
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
    
    func formatDate(date: Date) -> [String:String] {
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        print("EXACT_DATE : \(dateString)")
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MM"
        let numbermonth = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "YYYY"
        let year = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date)
        
        
        let monthNames = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
        let monthAbrs = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"]
        let dictPtBrWeekdays: [String:String] = ["Sunday": "Domingo", "Monday": "Segunda-Feira", "Tuesday": "Terça-Feira", "Wednesday": "Quarta-Feira", "Thursday":"Quinta-Feira", "Friday":"Sexta-Feira", "Saturday":"Sábado"]

        
        let dictDate: [String:String] = ["day": day, "month": monthAbrs[(Int(numbermonth) ?? 1)-1], "year": year
            , "weekday": dictPtBrWeekdays[weekday] ?? "", "time": time, "date": "\(day)/\(numbermonth)/\(year)"]
        
        return dictDate
    }

}
