//
//  AboutEmbassiesVC.swift
//  EGVApp
//
//  Created by Fabricio on 26/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AboutEmbassiesVC: UIViewController {

    
    @IBOutlet weak var mLbAboutText: UILabel!
    
    
    var mUser: User!
    private var mDatabase: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mDatabase = MyFirebase.sharedInstance.database()
        self.getAboutEmbassy()
        // Do any additional setup after loading the view.
    }
    
    private func getAboutEmbassy() {
    
        self.mDatabase.collection(MyFirebaseCollections.APP_CONTENT)
            .document("about_embassy")
            .getDocument(completion: { (documentSnapshot, error) in
                
                if let document = documentSnapshot {
                    if let documentData = document.data() {
                        let text = documentData["value"] as! String
                        let bodyHTML = "<span style='font-family: \"-apple-system\", \"HelveticaNeue\" ; font-size:16;  color:#4D4D4F'; padding: 0; margin: 0;>\(text)</span>"
                        let data = Data(bodyHTML.utf8)
                        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                            self.mLbAboutText.attributedText = attributedString
                        }
                        
                    }
                }
                
            })
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
