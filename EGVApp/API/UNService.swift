//
//  UNService.swift
//  EGVApp
//
//  Created by Fabricio on 18/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import UserNotifications

class UNService: NSObject {
    private override init(){}
    static let shared = UNService()
    let unCenter = UNUserNotificationCenter.current()
    
    func autorize() {
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        unCenter.requestAuthorization(options: options) { (granted, error) in
            print(error ?? "no un authorization error")
            guard granted else {return}
            DispatchQueue.main.async {
                self.configure()
            }
        }
    }
    
    func configure() {
        unCenter.delegate = self
        
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
    }
}

extension UNService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("un did receive")
        
        print("notification_info", response.notification.request.content.userInfo)
        
        let userInfo = response.notification.request.content.userInfo
        
        let aps = userInfo["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: Any]
        let sender = alert?["title"] as? String
        let body = alert?["body"] as? String
        let category = aps?["category"] as? String
        
        print("notification_info sender", sender)
        print("notification_info body", body)
        print("notification_info category", category)
        
        
        //completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("un will present")
        
        let userInfo = notification.request.content.userInfo
        
        let aps = userInfo["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: Any]
        let sender = alert?["title"] as? String
        let body = alert?["body"] as? String
        let category = aps?["category"] as? String
        
        print("notification_info sender", sender)
        print("notification_info body", body)
        print("notification_info category", category)
        
        //completionHandler([])
    }
}
