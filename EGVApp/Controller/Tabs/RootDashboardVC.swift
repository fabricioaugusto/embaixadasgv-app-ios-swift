//
//  RootDashboardViewController.swift
//  EGVApp
//
//  Created by Fabricio on 10/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RootDashboardVC: UIViewController {

    
    var mUser: User!
    @IBOutlet weak var mBtMembers: UIButton!
    @IBOutlet weak var mBtEvents: UIButton!
    @IBOutlet weak var mBtPhotos: UIButton!
    @IBOutlet weak var mBtCloud: UIButton!
    @IBOutlet var viewsToSet: [CenteredButton]!
    @IBOutlet var viewsToFormat: [UIView]!
    @IBOutlet weak var mLbEventAbbrMonth: UILabel!
    @IBOutlet weak var mLbEventDay: UILabel!
    @IBOutlet weak var mLbEventTime: UILabel!
    @IBOutlet weak var mLbEventTheme: UILabel!
    @IBOutlet weak var mLbEventEmbassy: UILabel!
    
    @IBOutlet weak var mViewContainerEvent: UIView!
    @IBOutlet weak var mLbNoEvents: UILabel!
    private var mDatabase: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("evgapplog root", mUser.id)
        mDatabase = MyFirebase.sharedInstance.database()
        setLayout()
        getNextEvent()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtNotifications(_ sender: UIBarButtonItem) {
        self.makeAlert(message: "Este recurso estará disponível nas próximas atualizações!")
    }
    
    
    @IBAction func onClickBtEmbassyMembers(_ sender: UIButton) {
        performSegue(withIdentifier: "embassyMembersSegue", sender: nil)
    }
    
    @IBAction func onClickBtEmbassyEvents(_ sender: UIButton) {
        performSegue(withIdentifier: "embassyEventsSegue", sender: nil)
    }
    
    @IBAction func onClickBtEmbassyPhotos(_ sender: UIButton) {
        performSegue(withIdentifier: "embassyPhotosSegue", sender: nil)
    }
    
    @IBAction func onClickBtEmbassyCloud(_ sender: UIButton) {
        self.makeAlert(message: "Este recurso estará disponível nas próximas atualizações!")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embassyMembersSegue" {
            let vc = segue.destination as! EmbassyMembersTableVC
            vc.mUser = mUser
            vc.mEmbassyID = mUser.embassy_id
        }
        
        if segue.identifier == "embassyEventsSegue" {
            let vc = segue.destination as! EmbassyEventsTableVC
            vc.mUser = mUser
            vc.mEmbassyID = mUser.embassy_id
        }
        
        if segue.identifier == "embassyPhotosSegue" {
            let vc = segue.destination as! EmbassyPhotosCollectionVC
            vc.mEmbassyID = mUser.embassy_id
            vc.mUser = mUser
        }
    }
    
    private func getNextEvent() {
        let today = Date()
        let timestamp = Timestamp(date: today)
        
        self.mDatabase?.collection(MyFirebaseCollections.EVENTS)
            .whereField("embassy_id", isEqualTo: mUser.embassy_id ?? "")
            .whereField("date", isGreaterThan: timestamp)
            .order(by: "date", descending: false)
            .limit(to: 1)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let query = querySnapshot {
                        if query.documents.count > 0 {
                            //self.mLastDocument = query.documents[query.count - 1]
                            for document in querySnapshot!.documents {
                                if let event = Event(dictionary: document.data()) {
                                   self.bindEvent(event: event)
                                }
                            }
                        } else {
                            self.mLbNoEvents.isHidden = false
                        }
                    }
                    
                }
            })
    }
    
    private func bindEvent(event: Event) {
        if let stamp = event.date {
            let date = stamp.dateValue()
            print("egvapplogevent", date)
            let formattedDate = FormatDate().dateToString(date: date)
            mLbEventDay.text = formattedDate["day"]
            mLbEventAbbrMonth.text = formattedDate["month"]?.uppercased()
            mLbEventTime.text = "\(String(describing: formattedDate["weekday"]!)) às \(String(describing: formattedDate["time"]!))".uppercased()
        }
        
        mLbEventTheme.text = event.theme
        mLbEventEmbassy.text = "\(String(describing: event.embassy?.name ?? "")) - \(String(describing: event.city ?? "")), \(String(describing: event.state_short ?? ""))"
        mViewContainerEvent.isHidden = false
    }
    
    func setLayout() {
        
        for button in viewsToSet {
            button.layer.cornerRadius = 5
            button.layer.borderColor = AppColors.colorBorderGrey.cgColor
            button.layer.borderWidth = 1
        }
        
        for view in viewsToFormat {
            view.layer.cornerRadius = 5
            view.layer.borderColor = AppColors.colorBorderGrey.cgColor
            view.layer.borderWidth = 1
        }
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Em breve!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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

class CenteredButton: UIButton
{
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let imageRect = super.imageRect(forContentRect: contentRect)
        
        return CGRect(x: 0, y: imageRect.maxY,
                      width: contentRect.width, height: rect.height)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)
        
        return CGRect(x: contentRect.width/2.0 - rect.width/2.0,
                      y: (contentRect.height - titleRect.height)/2.0 - rect.height/2.0,
                      width: rect.width, height: rect.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }
    
    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .center
    }
}
