//
//  RegisterModeratorVC.swift
//  EGVApp
//
//  Created by Fabricio on 13/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseFirestore
import FirebaseStorage
import KMPlaceholderTextView
import JGProgressHUD
import YPImagePicker

protocol RegisterModeratorDelegate: class {
    func onRegisterModerator(vc: RegisterModeratorVC)
}

class RegisterModeratorVC: UIViewController {
    
    @IBOutlet weak var mImgModeratorProfile: UIImageView!
    @IBOutlet weak var mSelectProfilePhoto: UIButton!
    @IBOutlet weak var mSvFormFields: UIStackView!
    @IBOutlet weak var mBiographyField: KMPlaceholderTextView!
    @IBOutlet weak var mBiographyContainer: UIView!
    
    weak var delegate: ManageModeratorsTableVC!
    
    var mUser: User!
    private var mHud: JGProgressHUD!
    private var mDatabase: Firestore!
    private var mNameField: SkyFloatingLabelTextField!
    private var mOccupationField: SkyFloatingLabelTextField!
    private var mEmailField: SkyFloatingLabelTextField!
    private var tempImagePath: URL?
    private var mImageData: Data?
    private var mImageMetaData: StorageMetadata?
    private var imgExtension: String = ""
    private var mStorage: Storage!
    private var mPhotoSelected: Bool = false
    private var mModeratorDict: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addFields()
        mDatabase = MyFirebase.sharedInstance.database()
        mStorage = MyFirebase.sharedInstance.storage()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Registrando..."
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickBtSaveModerator(_ sender: Any) {
        self.saveData()
    }
    
    
    @IBAction func onClickBtSelectPhoto(_ sender: UIButton) {
        self.startGalleryPicker()
    }
    

    private func addFields() {
        
        self.mNameField = buildTextField(placeholder: "Nome", icon: String.fontAwesomeIcon(name: .user))
        mSvFormFields.insertArrangedSubview(self.mNameField, at: 0)
        
        self.mOccupationField = buildTextField(placeholder: "Área de Atuação", icon: String.fontAwesomeIcon(name: .briefcase))
        mSvFormFields.insertArrangedSubview(self.mOccupationField, at: 1)
        
        AppLayout.addLineToView(view: mBiographyContainer, position: .LINE_POSITION_BOTTOM, color: AppColors.colorGrey, width: 1.0)
        //svFormFields.insertArrangedSubview(self.mBiographyField!, at: 3)
        
        
        mSvFormFields.alignment = .fill
        mSvFormFields.distribution = .fill
        mSvFormFields.axis = .vertical
        mSvFormFields.spacing = 24
        
        //bindData()
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
    
    private func startGalleryPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.library.onlySquare = true
        config.showsPhotoFilters = false
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
                    self.mImageData = photo.image.pngData()
                    self.mImageMetaData?.contentType = "image/png"
                    try! self.mImageData?.write(to: imagePath!)
                } else {
                    self.mImageMetaData?.contentType = "image/jpeg"
                    self.mImageData = photo.image.jpegData(compressionQuality: 0.70)
                    try! self.mImageData?.write(to: imagePath!)
                }
                self.tempImagePath = imagePath!
                self.mPhotoSelected = true
                self.mImgModeratorProfile.image = photo.image
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    private func saveData() {
        
        let name = mNameField.text ?? ""
        let occupation = mOccupationField.text ?? ""
        let biography = mBiographyField.text ?? ""
        
        if(name.isEmpty) {
            makeAlert(message: "O campo 'Nome' precia ser preenchido")
            return
        }

        if(occupation.isEmpty) {
            makeAlert(message: "O campo 'Área de Atuação' precia ser preenchido")
            return
        }

        if(biography.isEmpty) {
            makeAlert(message: "O campo 'Biografia' precia ser preenchido")
            return
        }
            
        if (!self.mPhotoSelected) {
            makeAlert(message: "Você precisa escolher uma foto")
            return
        }
        
        mHud.show(in: self.view)
        
        mModeratorDict["name"] = name
        mModeratorDict["occupation"] = occupation
        mModeratorDict["description"] = biography
        mModeratorDict["embassy_id"] = mUser.embassy_id
        mModeratorDict["user_id"] = NSNull()
        
        self.uploadToStorage()
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
                
                self.mModeratorDict["profile_img"] = downloadURL.absoluteString
                
                var ref: DocumentReference? = nil
                
                ref = self.mDatabase.collection(MyFirebaseCollections.MODERATORS)
                    .addDocument(data: self.mModeratorDict) { (error) in
                        ref?.updateData(["id": ref!.documentID])
                        self.delegate.onRegisterModerator(vc: self)
                        self.mHud.dismiss()
                        self.navigationController?.popViewController(animated: true)
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
