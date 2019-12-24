//
//  SingleNotificationVC.swift
//  EGVApp
//
//  Created by Fabricio on 19/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SingleNotificationVC: UIViewController {

    
    @IBOutlet weak var mImgNotificationCover: UIImageView!
    @IBOutlet weak var mLbNotificationTitle: UILabel!
    @IBOutlet weak var mLbNotificationSubtitle: UILabel!
    @IBOutlet weak var mLbNotificationDate: UILabel!
    @IBOutlet weak var mLbNotificationText: UITextView!
    
    var mNotificationID: String!
    private var mNotification: Notification!
    private var mDatabase: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mDatabase = MyFirebase.sharedInstance.database()
        self.getNotificationDetails()
        // Do any additional setup after loading the view.
    }
    
    private func getNotificationDetails() {
        mDatabase.collection(MyFirebaseCollections.NOTIFICATIONS)
        .document(mNotificationID)
            .getDocument { (documentSnapshot, error) in
                if error == nil {
                    if let notification = documentSnapshot.flatMap({
                        $0.data().flatMap({ (data) in
                            return Notification(dictionary: data)
                        })
                    }) {
                        self.mNotification = notification
                        self.bindData()
                        
                    } else {
                        print("Document not exists")
                    }
                }
        }
    }
    
    private func bindData() {
        mLbNotificationTitle.text = mNotification.title
        mLbNotificationSubtitle.text = mNotification.description
        
        let bodyHTML = "<span style='font-family: \"-apple-system\", \"HelveticaNeue\" ; font-size:16;  color:#4D4D4F'; padding: 0; margin: 0;>\(mNotification.text)</span>"
        if let htmldata = bodyHTML.data(using: String.Encoding.isoLatin1), let attributedString = try? NSAttributedString(data: htmldata, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            mLbNotificationText.attributedText = attributedString
        }
                
        if let stamp = mNotification.created_at {
            let date = stamp.dateValue()
            let formattedDate = FormatDate().dateToString(date: date)
            mLbNotificationDate.text = "\(String(describing: formattedDate["date"]!)) às \(String(describing: formattedDate["time"]!))"
        }
        
        if !mNotification.picture.isEmpty {
            let url = URL(string: mNotification.picture)
            mImgNotificationCover.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        } else {
            let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/assets%2Fimages%2Fbg_egv_logo.png?alt=media&token=90971d90-b517-47c5-a3c8-cede129cba3e")
            mImgNotificationCover.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
