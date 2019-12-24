//
//  ChooseProfilePhotoVC.swift
//  EGVApp
//
//  Created by Fabricio on 18/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import YPImagePicker
import SwiftHash
import JGProgressHUD

class ChooseProfilePhotoVC: UIViewController {

    
    @IBOutlet weak var mImgUserProfile: UIImageView!
    
    var mUser: User!
    var tempImagePath: URL?
    var mImageData: Data?
    var mImageMetaData: StorageMetadata?
    var imgExtension: String = ""
    var mStorage: Storage!
    var mDatabase: Firestore!
    var mPhotoSelected: Bool = false
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mStorage = MyFirebase.sharedInstance.storage()
        mDatabase = MyFirebase.sharedInstance.database()
        
        mImgUserProfile.layer.cornerRadius = 90
        mImgUserProfile.layer.masksToBounds = true
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Registrando..."
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtChoosePhoto(_ sender: UIButton) {
        startGalleryPicker()
    }
    
    @IBAction func onClickSavePhotoBt(_ sender: Any) {
        uploadToStorage()
    }
    
    
    private func startGalleryPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.library.onlySquare = true
        config.showsPhotoFilters = false
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, cancelled in
        
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
                self.mImgUserProfile.image = photo.image
            }
            
            
        }
        self.present(picker, animated: true, completion: nil)

    }
    
    private func uploadToStorage() {
        
        if(!mPhotoSelected) {
            makeAlert(message: "Você precisa selecionar uma foto de perfil")
            return
        }
        
        self.mHud.show(in: self.view)
        
        // Data in memory
        if let data = mImageData {
            // Create a reference to the file you want to upload
            let riversRef = mStorage.reference().child("ios_images/rivers.jpg")

            // Upload the file to the path "images/rivers.jpg"
            riversRef.putData(data, metadata: self.mImageMetaData)
            { (metadata, error) in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }
                
              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
              riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
                
                print("egvapplog", downloadURL.absoluteString)
                self.mDatabase
                    .collection(MyFirebaseCollections.USERS)
                    .document(self.mUser.id)
                    .updateData(["profile_img" : downloadURL.absoluteString, "status": "active"]) { (err) in
                        if let err = err {
                            
                        } else {
                            self.mHud.dismiss()
                            self.startCheckAuthVC()
                            //Doc Updated
                        }
                }
              }
            }
        }
    }
    
    private func startCheckAuthVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckAuthVC") as! CheckAuthVC
        UIApplication.shared.keyWindow?.rootViewController = vc
        return
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
