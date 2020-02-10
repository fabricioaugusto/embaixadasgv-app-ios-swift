//
//  CreateEventVC.swift
//  EGVApp
//
//  Created by Fabricio on 11/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import GooglePlaces
import FirebaseFirestore
import FirebaseStorage
import YPImagePicker
import KMPlaceholderTextView
import JGProgressHUD


protocol CreateEventDelegate: class {
    func onCreateEvent(vc: CreateEventVC)
}

class CreateEventVC: UIViewController, SelectModeratorDelegate {
    
    @IBOutlet weak var mImgCoverPhoto: UIImageView!
    @IBOutlet weak var mSvFormFields: UIStackView!
    @IBOutlet weak var mSvDatetimeFields: UIStackView!
    @IBOutlet weak var mImgModeratorProfile: UIImageView!
    @IBOutlet weak var mLbModeratorName: UILabel!
    @IBOutlet weak var mLbModeratorDescription: UILabel!
    
    @IBOutlet weak var mBiographyField: KMPlaceholderTextView!
    @IBOutlet weak var mBiographyContainer: UIView!
    @IBOutlet weak var mViewModeratorContainer: UIView!
    @IBOutlet weak var mBtAddModerator: UIButton!
    
    weak var delegate: ManageEventsTableVC!
    
    var mUser: User!
    var mEvent: [String:Any] = [:]
    private var mDatabase: Firestore!
    private var tempImagePath: URL?
    private var mImageData: Data?
    private var mImageMetaData: StorageMetadata?
    private var imgExtension: String = ""
    private var mStorage: Storage!
    private var mPhotoSelected: Bool = false
    private var mPostImgWidth: Int = 0
    private var mPostImageHeight: Int = 0
    private var mThemeField: SkyFloatingLabelTextField!
    private var mDateField: SkyFloatingLabelTextField!
    private var mTimeField: SkyFloatingLabelTextField!
    private var mLocationField: SkyFloatingLabelTextField!
    private var mkeyboardWillShowObserver: NSObjectProtocol!
    private var mkeyboardWillHideObserver: NSObjectProtocol!
    private var mTabBarHeight: CGFloat = 0
    private var mCurrentKeyboardHeight: CGFloat = 0.0
    private var mHud: JGProgressHUD!
    private var mSelectedModerator: Moderator?
    private var mSelectedPlace: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mDatabase = MyFirebase.sharedInstance.database()
        mStorage = MyFirebase.sharedInstance.storage()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Salvando..."
        
        addFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         mTabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        
        let center = NotificationCenter.default
        
        self.mkeyboardWillShowObserver = center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let height = value.cgRectValue.height
            
            print(self.view.frame.origin.y)
        
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= height - self.mTabBarHeight
            } else if self.view.frame.origin.y == (0 - (self.mCurrentKeyboardHeight - self.mTabBarHeight)) {
                self.view.frame.origin.y = 0 - (height - self.mTabBarHeight)
            }
            
            self.mCurrentKeyboardHeight = height
            // use the height of the keyboard to layout your UI so the prt currently in
            // foxus remains visible
        }
        
        self.mkeyboardWillHideObserver = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    
    @IBAction func onClickBtSaveEvent(_ sender: UIBarButtonItem) {
        self.saveData()
    }
    
    
    @IBAction func onClickBtChangeCover(_ sender: UIButton) {
        self.startGalleryPicker()
    }
    
    
    
    private func addFields() {
        
        self.mThemeField = buildTextField(placeholder: "Tema", icon: String.fontAwesomeIcon(name: .book))
        mSvFormFields.insertArrangedSubview(self.mThemeField, at: 0)
        
        self.mDateField = buildTextField(placeholder: "Data", icon: String.fontAwesomeIcon(name: .calendarAlt))
        mSvDatetimeFields.insertArrangedSubview(self.mDateField, at: 0)
        
        self.mTimeField = buildTextField(placeholder: "Hora", icon: String.fontAwesomeIcon(name: .clock))
        mSvDatetimeFields.insertArrangedSubview(self.mTimeField, at: 1)
        
        self.mLocationField = buildTextField(placeholder: "Localização", icon: String.fontAwesomeIcon(name: .mapMarkerAlt))
        mSvFormFields.insertArrangedSubview(self.mLocationField, at: 2)
        
        AppLayout.addLineToView(view: mBiographyContainer, position: .LINE_POSITION_BOTTOM, color: AppColors.colorGrey, width: 1.0)
        
        mDateField.delegate = self
        mTimeField.delegate = self
        mLocationField.delegate = self
        mSvFormFields.alignment = .fill
        mSvFormFields.distribution = .fill
        mSvFormFields.axis = .vertical
        mSvFormFields.spacing = 24
        
    }
    
    
    private func buildTextField(placeholder: String, icon: String) -> SkyFloatingLabelTextField {
        
        let textField = SkyFloatingLabelTextFieldWithIcon(frame: CGRect(x: 10, y: 10, width: 120, height: 64))
        textField.placeholder = placeholder
        textField.title = placeholder
        textField.tintColor = AppColors.colorAccent// the color of the blinking cursor
        textField.textColor = AppColors.colorText
        textField.lineColor = AppColors.colorGrey
        textField.selectedTitleColor = AppColors.colorAccent
        textField.selectedLineColor = AppColors.colorAccent
        textField.lineHeight = 1.0 // bottom line height in points
        textField.iconFont = UIFont.fontAwesome(ofSize: 18, style: .solid)
        textField.iconText = icon
        textField.iconMarginBottom = 1
        textField.selectedLineHeight = 2.0
        
        return textField
    }
    
    func presentActionSheet() {
        let alert = UIAlertController(title: "Seleciona uma opção", message: "O que você deseja fazer?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Selecionar cadastrado", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "searchModeratorSegue", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cadastrar manualmente", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "registerModeratorSegue", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func startGalleryPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.showsCrop = .rectangle(ratio: 3/2)
        config.wordings.next = "Avançar"
        config.wordings.cancel = "Cancelar"
        config.wordings.libraryTitle = "Galeria"
        config.colors.tintColor = AppColors.colorLink
        
        let picker = YPImagePicker(configuration: config)
        
        UINavigationBar.appearance().tintColor = AppColors.colorText
        
        if #available(iOS 13.0, *) {
            picker.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            UINavigationBar.appearance().tintColor = .white
            
            if cancelled {
                picker.dismiss(animated: true, completion: nil)
            }
        
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
                
                picker.dismiss(animated: true, completion: nil)
                //obtaining saving path
                let fileManager = FileManager.default
                let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                let imagePath = documentsPath?.appendingPathComponent("temp."+self.imgExtension)
                self.mImageMetaData = StorageMetadata()
                if self.imgExtension == "png"{
                    self.imgExtension = "png"
                    self.mImageData = photo.image.pngData()
                    self.mImageMetaData?.contentType = "image/png"
                    try! self.mImageData?.write(to: imagePath!)
                } else {
                    self.imgExtension = "jpg"
                    self.mImageMetaData?.contentType = "image/jpeg"
                    self.mImageData = photo.image.jpegData(compressionQuality: 0.70)
                    try! self.mImageData?.write(to: imagePath!)
                }
                self.mPostImgWidth = Int(photo.image.size.width)
                self.mPostImageHeight = Int(photo.image.size.height)
                self.tempImagePath = imagePath!
                self.mPhotoSelected = true
                self.mImgCoverPhoto.image = photo.image
            }
            
        }
        self.present(picker, animated: true, completion: nil)

    }
    
    func onModeratorSelected(moderator: Moderator, vc: ManageModeratorsTableVC) {
        mLbModeratorName.text = moderator.name
        mLbModeratorDescription.text = moderator.occupation
        
        mImgModeratorProfile.layer.cornerRadius = 30
        mImgModeratorProfile.layer.masksToBounds = true
            
        mImgModeratorProfile.kf.indicatorType = .activity
            if let profile_img = moderator.profile_img {
                let url = URL(string: profile_img)
                mImgModeratorProfile.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "grey_circle"),
                    options: [
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
            }
        
        mViewModeratorContainer.isHidden = false
        mBtAddModerator.setTitle("Alterar Moderador", for: .normal)
        
        self.mSelectedModerator = moderator
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manageModeratorsSegue" {
            let vc = segue.destination as! ManageModeratorsTableVC
            vc.mUser = self.mUser
            vc.delegate = self
        }
    }
        
    private func saveData() {
        
        let theme = mThemeField.text ?? ""
        let description = mBiographyField.text ?? ""
        let date_str = mDateField.text ?? ""
        let time_str = mTimeField.text ?? ""
        
        if(theme.isEmpty) {
            makeAlert(message: "O campo 'Tema' precia ser preenchido")
            return
        }

        if(description.isEmpty) {
            makeAlert(message: "O campo 'Descrição do evento' precia ser preenchido")
            return
        }

            
        if self.mSelectedPlace == nil {
            makeAlert(message: "Você precisa selecionar uma localização")
            return
        }

        if let moderator = mSelectedModerator {
            self.mEvent["moderator_1"] = moderator.toMap()
        } else {
            makeAlert(message: "Você precisa adicionar pelo menos um moderador para o evento")
            return
        }

        if(!date_str.isEmpty && !time_str.isEmpty) {
            
            
            let isoDate = "\(date_str) \(time_str)"

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            let date = dateFormatter.date(from:isoDate)!
            
            self.mEvent["date"] = Timestamp(date: date)
            

        } else {
            makeAlert(message: "A data e horário precisam ser preenchidos")
            return
        }
        
        self.mHud.show(in: self.view)
        
        self.mEvent["theme"] = theme
        self.mEvent["description"] = description
        self.mEvent["embassy"] = mUser.embassy?.toBasicMap()
        self.mEvent["embassy_id"] = mUser.embassy_id
        
        
        if(mPhotoSelected) {
            self.uploadToStorage()
        } else {
            self.mEvent["cover_img"] = NSNull()
            
            var ref: DocumentReference? = nil
            
            ref = self.mDatabase.collection(MyFirebaseCollections.EVENTS)
                .addDocument(data: self.mEvent) { (error) in
                    if(error == nil) {
                        ref?.updateData(["id": ref!.documentID])
                        self.delegate.onCreateEvent(vc: self)
                        self.mHud.dismiss()
                        self.navigationController?.popViewController(animated: true)                    }
            }
        }
    }
    
    private func uploadToStorage() {
        
        
        // Data in memory
        if let data = mImageData {
            
            let uuid = UUID().uuidString
            let image_name = "\(uuid).\(self.imgExtension)"
            
            // Create a reference to the file you want to upload
            let postsImgRef = mStorage.reference().child("images/post/\(image_name)")

            // Upload the file to the path "images/rivers.jpg"
            postsImgRef.putData(data, metadata: self.mImageMetaData)
            { (metadata, error) in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }
                
              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
              postsImgRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
                
                self.mEvent["cover_img"] = downloadURL.absoluteString
                
                var ref: DocumentReference? = nil
                
                ref = self.mDatabase.collection(MyFirebaseCollections.EVENTS)
                    .addDocument(data: self.mEvent) { (error) in
                        if(error == nil) {
                            ref?.updateData(["id": ref!.documentID])
                            self.delegate.onCreateEvent(vc: self)
                            self.mHud.dismiss()
                            self.navigationController?.popViewController(animated: true)
                        }
                }
              }
            }
        }
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: UIAlertController.Style.alert)
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

extension CreateEventVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if let place_name = place.name {
            self.mEvent["place"] = place_name
            self.mSelectedPlace = place_name
            mLocationField.text = place_name
        }
        
        self.mEvent["address"] = place.formattedAddress
        
        self.mEvent["lat"] = place.coordinate.latitude
        self.mEvent["long"] = place.coordinate.longitude
        //.city = place.name
        
        if let components = place.addressComponents {
            print(components)
            for component in components {
                
                if(component.types[0] == "postal_code") {
                    self.mEvent["postal_code"] = component.name
                }
                
                if(component.types[0] == "country") {
                    self.mEvent["country"] = component.name
                }
                
                if(component.types[0] == "administrative_area_level_1") {
                    self.mEvent["state"] = component.name
                    
                    if let component_short_name = component.shortName {
                        self.mEvent["state_short"] = component_short_name
                    }
                }
                
                if(component.types[0] == "administrative_area_level_2") {
                    self.mEvent["city"] = component.name
                }
                
                if(component.types[0] == "route") {
                    self.mEvent["street"] = component.name
                }
                
                if(component.types[0] == "street_number") {
                    self.mEvent["street_number"] = component.name
                }
            }
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


extension CreateEventVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == mLocationField {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            
            if #available(iOS 13.0, *) {
                autocompleteController.overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
            
            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) |
                UInt(GMSPlaceField.formattedAddress.rawValue) |
                UInt(GMSPlaceField.addressComponents.rawValue) |
                UInt(GMSPlaceField.coordinate.rawValue))!
            autocompleteController.placeFields = fields
            
            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            filter.type = .noFilter
            autocompleteController.autocompleteFilter = filter
            
            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == mDateField {
            if textField.text?.count == 2 || textField.text?.count == 5 {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    textField.text = textField.text! + "/"
                }
            }
            // check the condition not exceed 9 chars
            return !(textField.text!.count > 9 && (string.count ) > range.length)
        } else if textField == mTimeField {
            if textField.text?.count == 2 {
                //Handle backspace being pressed
                if !(string == "") {
                    // append the text
                    textField.text = textField.text! + ":"
                }
            }
            // check the condition not exceed 9 chars
            return !(textField.text!.count > 4 && (string.count ) > range.length)
        } else {
            return true
        }
    }
}
