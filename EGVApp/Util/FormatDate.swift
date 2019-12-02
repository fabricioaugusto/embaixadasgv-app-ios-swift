//
//  FormatDate.swift
//  EGVApp
//
//  Created by Fabricio on 30/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import Foundation

class FormatDate {
    
    func dateToString(date: Date) -> [String:String] {
        
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
