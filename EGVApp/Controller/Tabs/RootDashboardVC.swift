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
    
    
    @IBOutlet weak var mBtRateApp: UIButton!
    @IBOutlet weak var mBtAboutEmbassies: UIButton!
    @IBOutlet weak var mBtEmbassyList: UIButton!
    @IBOutlet weak var mBtManageEvents: UIButton!
    @IBOutlet weak var mBtAddEmbassyPhotos: UIButton!
    @IBOutlet weak var mBtApproveMembersRequest: UIButton!
    
    @IBOutlet weak var mSvInvitationLink: UIStackView!
    @IBOutlet weak var mViewLinkContainer: UIView!
    @IBOutlet weak var mLbInvitationLink: UILabel!
    
    @IBOutlet weak var mViewRequestsCountContainer: UIView!
    @IBOutlet weak var mLbRequestsCount: UILabel!
    
    @IBOutlet weak var mLbDashboardPostTitle: UILabel!
    @IBOutlet weak var mLbDashboardPostDescription: UILabel!
    @IBOutlet weak var mImgDashboardPostPicture: UIImageView!
    @IBOutlet weak var mBtDashboardPostActionButton: UIButton!
    @IBOutlet weak var mViewDashboardPostContainer: UIView!
    @IBOutlet weak var mSvDashboardPostAction: UIStackView!
    
    private var mDatabase: Firestore!
    private var mListNotifications: [Notification] = []
    private var mLinkPostButtonAction: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mDatabase = MyFirebase.sharedInstance.database()
        
        if let last_read_notification = mUser.last_read_notification {
            getListNotifications(timestamp: last_read_notification)
        }
        
        setLayout()
        getNextEvent()
        getDashboardPost()
        
        if(mUser.leader) {
            mSvInvitationLink.isHidden = false
            getRequestorsList()
        }
    }
    
    @IBAction func onClickBtNotifications(_ sender: UIBarButtonItem) {
        self.makeAlert(message: "Este recurso estará disponível nas próximas atualizações!")
    }
    
    @IBAction func onClickBtCopyLink(_ sender: Any) {
        
        let username: String = mUser.username ?? ""
        
        UIPasteboard.general.string = "https://embaixadasgv.app/convite/\(username)"
        
        let alert = UIAlertController(title: "Link Copiado", message: "O link foi copiado com sucesso!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickBtAboutEmbassies(_ sender: UIButton) {
        performSegue(withIdentifier: "aboutEmbassySegue", sender: nil)
    }
    
    @IBAction func onClickBtRateApp(_ sender: UIButton) {
        let url = URL(string: "https://apps.apple.com/br/app/egvapp/id1489822815")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    
    
    @IBAction func onClickBtEmbassyList(_ sender: UIButton) {
        performSegue(withIdentifier: "embassyListSegue", sender: nil)
    }
    
    @IBAction func onClickBtManageEvents(_ sender: UIButton) {
        performSegue(withIdentifier: "manageEventsSegue", sender: nil)
    }
    
    @IBAction func onClickBtManagePhotos(_ sender: UIButton) {
        performSegue(withIdentifier: "managePhotosSegue", sender: nil)
    }
    
    @IBAction func onClickBtApproveMembersRequest(_ sender: UIButton) {
        performSegue(withIdentifier: "invitationRequestsSegue", sender: nil)
    }
    
    @IBAction func onClickBtPotsButtonAction(_ sender: Any) {
        
        if(!self.mLinkPostButtonAction.isEmpty) {
            let url = URL(string: self.mLinkPostButtonAction)
            
            if let url = url {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embassyMembersSegue" {
            let vc = segue.destination as! EmbassyMembersTableVC
            vc.mUser = mUser
            vc.mEmbassyID = mUser.embassy_id
        }
        
        if segue.identifier == "aboutEmbassySegue" {
            let vc = segue.destination as! AboutEmbassiesVC
            vc.mUser = self.mUser
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
        
        if segue.identifier == "notificationsSegue" {
            let vc = segue.destination as! NotificationsTableVC
            vc.mUser = self.mUser
            vc.mRoodDashboardVC = self
        }
        
        if segue.identifier == "manageEventsSegue" {
            let vc = segue.destination as! ManageEventsTableVC
            vc.mUser = self.mUser
            vc.mEmbassyID = self.mUser.embassy_id
        }
        
        if segue.identifier == "managePhotosSegue" {
            let vc = segue.destination as! ManagePhotosCollectionVC
            vc.mUser = self.mUser
            vc.mEmbassyID = self.mUser.embassy_id
        }
        
        if segue.identifier == "embassyListSegue" {
            let vc = segue.destination as! ListEmbassyTableVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "invitationRequestsSegue" {
            let vc = segue.destination as! InvitationRequestsTableVC
            vc.mUser = self.mUser
        }
    }
    
    
    private func getListNotifications(timestamp: Timestamp) {

        //isPostsOver = false

        mDatabase.collection(MyFirebaseCollections.NOTIFICATIONS)
            .whereField("created_at", isGreaterThan: timestamp)
            .whereField("receiver_id", isEqualTo: mUser.id)
            .order(by: "created_at", descending: true)
            .getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let documents = querySnapshot?.documents {
                        for document in documents {
                            if let notification = Notification(dictionary: document.data()) {
                                self.mListNotifications.append(notification)
                            }
                        }
                        self.getManagerNotifications(timestamp: timestamp)
                    }
                }
        }
    }
    
    private func getManagerNotifications(timestamp: Timestamp) {
        
        
        mDatabase.collection(MyFirebaseCollections.NOTIFICATIONS)
            .whereField("created_at", isGreaterThan: timestamp)
            .whereField("type", isEqualTo: "manager_notification")
            .whereField("only_leaders", isEqualTo: false)
            .order(by: "created_at", descending: true)
            .limit(to: 30)
            .getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let documents = querySnapshot?.documents {
                        for document in documents {
                            if let notification = Notification(dictionary: document.data()) {
                                self.mListNotifications.append(notification)
                            }
                        }
                        
                        if(self.mUser.leader) {
                            self.getLeaderNotifications(timestamp: timestamp)
                        } else {
                            self.setNotificationBarButton(count: self.mListNotifications.count)
                        }
            
                    }
                }
        }
    }
    
    private func getLeaderNotifications(timestamp: Timestamp) {


        mDatabase.collection(MyFirebaseCollections.NOTIFICATIONS)
            .whereField("created_at", isGreaterThan: timestamp)
            .whereField("type", isEqualTo: "manager_notification")
            .whereField("only_leaders", isEqualTo: true)
            .order(by: "created_at", descending: true)
            .limit(to: 30)
            .getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let documents = querySnapshot?.documents {
                        for document in documents {
                            if let notification = Notification(dictionary: document.data()) {
                                self.mListNotifications.append(notification)
                            }
                        }
                        self.setNotificationBarButton(count: self.mListNotifications.count)
                    }
                }
        }

    }
    
    func clearCountNotificationBarButton() {
        self.setNotificationBarButton(count: 0)
    }
    
    private func setNotificationBarButton(count: Int) {
        let notificationButton = SSBadgeButton()
        notificationButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        notificationButton.setImage(UIImage(named: "icon_notifications")?.withRenderingMode(.alwaysTemplate), for: .normal)
        notificationButton.badgeEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 15)
        
        if count > 0 {
            notificationButton.badge = String(count)
        } else {
            notificationButton.badge = nil
        }
        notificationButton.addTarget(self, action: #selector(onClickBtStartNotificationTableVC), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationButton)
    }
    
    @objc func onClickBtStartNotificationTableVC(sender: UIButton!) {
        performSegue(withIdentifier: "notificationsSegue", sender: nil)
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
    
    private func getRequestorsList() {
                
        mDatabase.collection(MyFirebaseCollections.INVITATION_REQUEST)
            .whereField("leaderId", isEqualTo: mUser.id)
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    if querySnapshot.documents.count > 0 {
                        self.mLbRequestsCount.text = "\(querySnapshot.documents.count)"
                        self.mViewRequestsCountContainer.isHidden = false
                    } else {
                        self.mViewRequestsCountContainer.isHidden = true
                    }
                }
        }
    }
    
    private func getDashboardPost() {
       
        self.mDatabase
        .collection("app_private_content")
        .document("post_dashboard")
            .getDocument { (documentSnapshot, error) in
                if let post = documentSnapshot.flatMap({
                    $0.data().flatMap({ (data) in
                        return Post(dictionary: data)
                    })
                }) {
                    self.mLbDashboardPostTitle.text = post.title
                    self.mLbDashboardPostDescription.text = post.text ?? ""
                    
                    if let post_link = post.link {
                        self.mLinkPostButtonAction = post_link
                    }
                    
                    if let action_button_text = post.action_button_text {
                        
                        
                        if(!action_button_text.isEmpty) {
                            AppLayout.addLineToView(view: self.mViewDashboardPostContainer, position: .LINE_POSITION_BOTTOM, color: AppColors.colorBorderGrey, width: 1.0)
                            self.mBtDashboardPostActionButton.text("\(action_button_text)")
                            self.mSvDashboardPostAction.isHidden = false
                        }
                    }
                    
                    if let post_picture = post.picture {
                                                
                        let url = URL(string: post_picture)
                        
                        if url != nil {
                            
                            self.setImageViewSize(aspectWith: post.picture_width, aspectHeight: post.picture_height)
                            self.mImgDashboardPostPicture.isHidden = false
                            
                            // kf
                            OperationQueue.main.addOperation {
                                self.mImgDashboardPostPicture.kf.setImage(
                                    with: url,
                                    placeholder: nil,
                                    options: [.transition(.fade(0.3))],
                                    progressBlock: nil,
                                    completionHandler: { _ in
                                })
                            }
                        
                        }
                        
                    }
                    
                } else {
                    
                    
                }
        }
    }
    
    private func setImageViewSize(aspectWith: Int, aspectHeight: Int) {
        let imageRatio = CGFloat(Float(aspectWith) / Float(aspectHeight))
        
        let constraint =  NSLayoutConstraint(item: self.mImgDashboardPostPicture,
              attribute: NSLayoutConstraint.Attribute.width,
              relatedBy: NSLayoutConstraint.Relation.equal,
              toItem: self.mImgDashboardPostPicture,
        attribute: NSLayoutConstraint.Attribute.height,
        multiplier: imageRatio,
        constant: 0)
        constraint.priority = UILayoutPriority(999)
        self.mImgDashboardPostPicture.translatesAutoresizingMaskIntoConstraints = false
        self.mImgDashboardPostPicture.addConstraint(constraint)
        
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
        
        if(mUser.leader) {
            let username: String = mUser.username ?? ""
            mLbInvitationLink.text = "https://embaixadasgv.app/convite/\(username)"
            
            mViewLinkContainer.layer.cornerRadius = 5
            mViewLinkContainer.layer.masksToBounds = true
            mViewLinkContainer.layer.borderColor = AppColors.colorBorderGrey.cgColor
            mViewLinkContainer.layer.borderWidth = 1.0
            
            mBtManageEvents.isHidden = false
            mBtAddEmbassyPhotos.isHidden = false
            mBtApproveMembersRequest.isHidden = false
            
            
            let manageEventsImage = UIImage(named: "icon_menu_calendar")
            let manageEventsTintedImage = manageEventsImage?.withRenderingMode(.alwaysTemplate)
            mBtManageEvents.setImage(manageEventsTintedImage, for: .normal)
            mBtManageEvents.tintColor = AppColors.colorLink
            mBtManageEvents.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            mBtManageEvents.imageView?.contentMode = .scaleAspectFit
            
            let addEmbassyPhotosImage = UIImage(named: "icon_menu_manager_photos")
            let addEmbassyPhotosTintedImage = addEmbassyPhotosImage?.withRenderingMode(.alwaysTemplate)
            mBtAddEmbassyPhotos.setImage(addEmbassyPhotosTintedImage, for: .normal)
            mBtAddEmbassyPhotos.tintColor = AppColors.colorLink
            mBtAddEmbassyPhotos.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            mBtAddEmbassyPhotos.imageView?.contentMode = .scaleAspectFit
            
            let approveMembersRequestImage = UIImage(named: "icon_menu_approve_embassies")
            let approveMembersRequestTintedImage = approveMembersRequestImage?.withRenderingMode(.alwaysTemplate)
            mBtApproveMembersRequest.setImage(approveMembersRequestTintedImage, for: .normal)
            mBtApproveMembersRequest.tintColor = AppColors.colorLink
            mBtApproveMembersRequest.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            mBtApproveMembersRequest.imageView?.contentMode = .scaleAspectFit
            
            mViewRequestsCountContainer.layer.cornerRadius = 12
        } else {
            
            mBtAboutEmbassies.isHidden = false
            mBtRateApp.isHidden = false
            
            let aboutEmbassiesImage = UIImage(named: "icon_menu_about_embassies")
            let aboutEmbassiesTintedImage = aboutEmbassiesImage?.withRenderingMode(.alwaysTemplate)
            mBtAboutEmbassies.setImage(aboutEmbassiesTintedImage, for: .normal)
            mBtAboutEmbassies.tintColor = AppColors.colorLink
            mBtAboutEmbassies.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            mBtAboutEmbassies.imageView?.contentMode = .scaleAspectFit
        }
        
        let rateAppImage = UIImage(named: "icon_menu_star")
        let rateAppTintedImage = rateAppImage?.withRenderingMode(.alwaysTemplate)
        mBtRateApp.setImage(rateAppTintedImage, for: .normal)
        mBtRateApp.tintColor = AppColors.colorLink
        mBtRateApp.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        mBtRateApp.imageView?.contentMode = .scaleAspectFit
        
        let embassyListImage = UIImage(named: "icon_menu_embasy_list")
        let embassyListTintedImage = embassyListImage?.withRenderingMode(.alwaysTemplate)
        mBtEmbassyList.setImage(embassyListTintedImage, for: .normal)
        mBtEmbassyList.tintColor = AppColors.colorLink
        mBtEmbassyList.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        mBtEmbassyList.imageView?.contentMode = .scaleAspectFit
        
    }
    
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Em breve!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

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
