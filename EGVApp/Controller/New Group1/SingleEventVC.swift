//
//  SingleEventVC.swift
//  EGVApp
//
//  Created by Fabricio on 13/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Kingfisher
import GoogleMaps
import FirebaseFirestore

class SingleEventVC: UIViewController {

    @IBOutlet weak var mImgEventCover: UIImageView!
    @IBOutlet weak var mLbEventAbbrMonth: UILabel!
    @IBOutlet weak var mLbEventDay: UILabel!
    @IBOutlet weak var mLbEventTime: UILabel!
    @IBOutlet weak var mLbEventTheme: UILabel!
    @IBOutlet weak var mLbEventEmbassy: UILabel!
    @IBOutlet weak var mLbEventDescription: UILabel!
    @IBOutlet weak var mImgModeratorProfile: UIImageView!
    @IBOutlet weak var mImgModeratorName: UILabel!
    @IBOutlet weak var mImgModeratorOccupation: UILabel!
    @IBOutlet weak var mLbEventPlace: UILabel!
    @IBOutlet weak var mLbEventAddress: UILabel!
    @IBOutlet weak var mViewEventMap: UIView!
    @IBOutlet weak var mBtEventEnroll: UIButton!
    @IBOutlet weak var mLbEnrollmentCount: UILabel!
    @IBOutlet weak var mUserEnrolled1: UIImageView!
    @IBOutlet weak var mUserEnrolled2: UIImageView!
    @IBOutlet weak var mUSerEnrolled3: UIImageView!
    @IBOutlet weak var mSvEventEnrollments: UIStackView!
    @IBOutlet weak var mBtReadMore: UIButton!
    
    @IBOutlet var mViewBoxContainters: [UIView]!
    
    
    var mUser: User!
    var mEvent: Event!
    private var mUserEnrollment: Enrollment!
    private var mDatabase: Firestore!
    var mapView:GMSMapView?
    var mUserEnrollmentList: [Enrollment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SingleEventVC.onTapStartEnrollmentList))
        mSvEventEnrollments.isUserInteractionEnabled = true
        mSvEventEnrollments.addGestureRecognizer(tap)
        
        mDatabase = MyFirebase.sharedInstance.database()
        
        for view in mViewBoxContainters {
            view.layer.cornerRadius = 5
            view.layer.borderColor = AppColors.colorBorderGrey.cgColor
            view.layer.borderWidth = 1
        }
        
        bindData()
        getEnrollments()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickEnrollBt(_ sender: UIButton) {
        if sender.isSelected {
            self.deleteEnrollment()
        } else {
            self.saveEnrollment()
        }
    }
    
    @IBAction func onClickReadMore(_ sender: UIButton) {
        if(sender.isSelected) {
            sender.isSelected = false
            sender.setTitle("Ver mais", for: .normal)
            mLbEventDescription.numberOfLines = 5
        } else {
            sender.isSelected = true
            sender.setTitle("Ver menos", for: .selected)
            mLbEventDescription.numberOfLines = 0
        }
    }
    
    private func getEnrollments() {
    
    mDatabase.collection(MyFirebaseCollections.ENROLLMENTS)
        .whereField("event_id", isEqualTo: mEvent.id)
        .getDocuments(completion: { (querySnapshot, error) in
            if let query = querySnapshot {
                for document in query.documents {
                    let enrollment = Enrollment(dictionary: document.data())
                    if let enrollment = enrollment {
                        self.mUserEnrollmentList.append(enrollment)
                        if(enrollment.user_id == self.mUser.id) {
                            self.mUserEnrollment = enrollment
                            self.mUserEnrollment.id = document.documentID
                            self.mBtEventEnroll.isSelected = true
                            self.mBtEventEnroll.text("Presença confirmada".uppercased())
                            self.mBtEventEnroll.titleLabel?.textColor = AppColors.colorWhite
                            self.mBtEventEnroll.tintColor = AppColors.colorGreen
                            self.mBtEventEnroll.backgroundColor = AppColors.colorGreen
                        }
                    }
                }
                self.bindEnrollment()
            }
        })
    }
    

    
    private func bindData() {
        
        if let cover_img = mEvent.cover_img {
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
        
        
        
        if self.mUserEnrollmentList.contains(where: { enrollment in enrollment.user_id == mUser.id }) {
            mBtEventEnroll.text("Presença confirmada")
        }
        
        
        
        if let moderator = mEvent.moderator_1 {
            
            mImgModeratorProfile.layer.cornerRadius = 25
            mImgModeratorProfile.layer.masksToBounds = true
            
            if let moderator_profile_img = moderator.profile_img {
                let url = URL(string: moderator_profile_img)
                mImgModeratorProfile.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "grey_circle"),
                    options: [
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
            }
            
            mImgModeratorName.text = moderator.name
            mImgModeratorOccupation.text = moderator.occupation ?? "Eu sou GV!"
        }
        
        if let stamp = mEvent.date {
            let date = stamp.dateValue()
            print("egvapplogevent", date)
            let formattedDate = formatDate(date: date)
            mLbEventDay.text = formattedDate["day"]
            mLbEventAbbrMonth.text = formattedDate["month"]?.uppercased()
            mLbEventTime.text = "\(String(describing: formattedDate["weekday"]!)) às \(String(describing: formattedDate["time"]!))".uppercased()
        }
        
        mLbEventTheme.text = mEvent.theme
        mLbEventEmbassy.text = "\(String(describing: mEvent.embassy?.name ?? "")) - \(String(describing: mEvent.city ?? "")), \(String(describing: mEvent.state_short ?? ""))"
        
        if mEvent.description.count > 265 {
           mLbEventDescription.numberOfLines = 5
        } else {
            mBtReadMore.isHidden = true
        }
        
        mLbEventDescription.text = mEvent.description
        mLbEventPlace.text = mEvent.place
        mLbEventAddress.text = mEvent.address
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let lat: Double = self.mEvent.lat ?? 0.0
        let lng: Double = self.mEvent.long ?? 0.0
        
        DispatchQueue.main.async {
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 16.0)
            self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: screenWidth, height: 300), camera: camera)
            self.mViewEventMap.addSubview(self.mapView!)
            
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            marker.title = "Delhi"
            marker.snippet = "India’s capital"
            marker.map = self.mapView
        }
    }
    
    private func bindEnrollment() {
    
        let enrollmentSize = self.mUserEnrollmentList.count
    
        if(enrollmentSize == 0){
            mLbEnrollmentCount.text = "Nenhuma pessoa confirmada até o momento"
        } else if (enrollmentSize == 1){
            mLbEnrollmentCount.text = "\(enrollmentSize) pessoa confirmada até o momento"
        } else if(enrollmentSize > 1) {
            mLbEnrollmentCount.text = "\(enrollmentSize) pessoas confirmadas até o momento"
        }
    
        if(enrollmentSize > 0) {
            mUserEnrolled1.isHidden = false
            let url = URL(string: mUserEnrollmentList[0].user.profile_img!)
            mUserEnrolled1.layer.cornerRadius = 10
            mUserEnrolled1.layer.masksToBounds = true
            mUserEnrolled1.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        } else {
            mUserEnrolled1.isHidden = true
        }
    
        if(enrollmentSize > 1) {
            mUserEnrolled2.isHidden = false
            let url = URL(string: mUserEnrollmentList[1].user.profile_img!)
            mUserEnrolled2.layer.cornerRadius = 10
            mUserEnrolled2.layer.masksToBounds = true
            mUserEnrolled2.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        } else {
            mUserEnrolled2.isHidden = true
        }
    
        if(enrollmentSize > 2) {
            mUSerEnrolled3.isHidden = false
            let url = URL(string: mUserEnrollmentList[2].user.profile_img!)
            mUSerEnrolled3.layer.cornerRadius = 10
            mUSerEnrolled3.layer.masksToBounds = true
            mUSerEnrolled3.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        } else {
            mUSerEnrolled3.isHidden = true
        }
    }
    
    private func saveEnrollment() {
    
        if !self.mUserEnrollmentList.contains(where: { enrollment in enrollment.user_id == mUser.id }) {
            
            self.mBtEventEnroll.isSelected = true
            self.mBtEventEnroll.text("Presença confirmada".uppercased())
            self.mBtEventEnroll.titleLabel?.textColor = AppColors.colorWhite
            self.mBtEventEnroll.tintColor = AppColors.colorGreen
            self.mBtEventEnroll.backgroundColor = AppColors.colorGreen
            
            let enrollment: [String: Any] = [
                "event": mEvent.toBasicMap(),
                "user" : mUser.toBasicMap(),
                "user_id" : mUser.id,
                "event_id" : mEvent.id,
                "event_date" : mEvent.date
            ]
            
        
            self.mUserEnrollment = Enrollment(dictionary: enrollment)
            self.mUserEnrollmentList.append(self.mUserEnrollment)
            
            self.bindEnrollment()
        
            var ref: DocumentReference? = nil
            ref = mDatabase.collection(MyFirebaseCollections.ENROLLMENTS)
                .addDocument(data: enrollment, completion: { (error) in
                    if error == nil {
                        self.mUserEnrollment.id = ref!.documentID
                        
                        ref!.updateData(["id": ref!.documentID], completion: { (error) in
                            if error == nil {
                                self.mBtEventEnroll.isEnabled = true
                            }
                        })
                    }
                })
        }
    }
    
    private func deleteEnrollment() {
    
        if self.mUserEnrollmentList.contains(where: { enrollment in enrollment.user_id == mUser.id }) {
            
            let list = mUserEnrollmentList.filter( { return $0.event_id == mEvent.id } )
    
            if(list.count > 0 ) {
                self.mBtEventEnroll.isSelected = false
                self.mBtEventEnroll.text("Confirmar presença".uppercased())
                self.mBtEventEnroll.setTitleColor(AppColors.colorWhite, for: .normal)
                self.mBtEventEnroll.tintColor = AppColors.colorRed
                self.mBtEventEnroll.backgroundColor = AppColors.colorRed
                
                self.mUserEnrollmentList = mUserEnrollmentList.filter( { return $0.user_id != mUser.id } )
    
                self.bindEnrollment()
    
                self.mDatabase.collection(MyFirebaseCollections.ENROLLMENTS)
                    .document(mUserEnrollment.id)
                    .delete { (error) in
                        if error == nil {
                            self.mBtEventEnroll.isEnabled = true
                        }
                }
                
            }
    
        }
    }
    
    @objc func onTapStartEnrollmentList(sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "enrollUsersSegue", sender: nil)
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enrollUsersSegue" {
            let vc = segue.destination as! ListUsersTableVC
            vc.mType = "enrollUsers"
            vc.mEventID = mEvent.id
            vc.mUser = mUser
        }
    }
    

}
