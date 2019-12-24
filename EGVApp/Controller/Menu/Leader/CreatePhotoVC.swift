//
//  CreatePhotoVC.swift
//  EGVApp
//
//  Created by Fabricio on 11/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import YPImagePicker
import SwiftHash
import JGProgressHUD
import KMPlaceholderTextView


protocol CreatePhotoDelegate: class {
    func onCreatePhoto(vc: CreatePhotoVC)
}

class CreatePhotoVC: UIViewController {
    
    @IBOutlet weak var mImgSelectPicture: UIImageView!
    @IBOutlet weak var mFieldPhotoDescription: KMPlaceholderTextView!
    
    weak var delegate: ManagePhotosCollectionVC!
    
    var mUser: User!
    private var mPhotoDict: [String: Any] = [:]
    private var tempImagePath: URL?
    private var mImageData: Data?
    private var mImageMetaData: StorageMetadata?
    private var imgExtension: String = ""
    private var mStorage: Storage!
    private var mDatabase: Firestore!
    private var mPhotoSelected: Bool = false
    private var mPostImgWidth: Int = 0
    private var mPostImageHeight: Int = 0
    private var mNSLayoutConstraint: NSLayoutConstraint?
    private var mDocumentReference: DocumentReference!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mDatabase = MyFirebase.sharedInstance.database()
        mStorage = MyFirebase.sharedInstance.storage()
        
        let onTapSelectPicture = UITapGestureRecognizer(target: self, action: #selector(CreatePhotoVC.onTapSelectPicture))
        mImgSelectPicture.isUserInteractionEnabled = true
        mImgSelectPicture.addGestureRecognizer(onTapSelectPicture)
        
        self.setImageViewSize(aspectWith: 4, aspectHeight: 3)
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Publicando..."
    }
    
    @IBAction func onClickBtSavePhoto(_ sender: UIBarButtonItem) {
        self.publishPhoto()
    }
    
    @objc func onTapSelectPicture(sender:UITapGestureRecognizer) {
        self.startGalleryPicker()
    }
    
    private func startGalleryPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
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
                self.mImgSelectPicture.image = photo.image
                self.setImageViewSize(aspectWith: self.mPostImgWidth, aspectHeight: self.mPostImageHeight)
            }
            
        }
        self.present(picker, animated: true, completion: nil)

    }
    
    private func setImageViewSize(aspectWith: Int, aspectHeight: Int) {
        let imageRatio = CGFloat(Float(aspectWith) / Float(aspectHeight))

        if let constraint = mNSLayoutConstraint {
            self.mImgSelectPicture.removeConstraint(constraint)
        }
        
        mNSLayoutConstraint =  NSLayoutConstraint(item: self.mImgSelectPicture,
              attribute: NSLayoutConstraint.Attribute.width,
              relatedBy: NSLayoutConstraint.Relation.equal,
              toItem: self.mImgSelectPicture,
        attribute: NSLayoutConstraint.Attribute.height,
        multiplier: imageRatio,
        constant: 0)
        mNSLayoutConstraint?.priority = UILayoutPriority(999)
        self.mImgSelectPicture.translatesAutoresizingMaskIntoConstraints = false
        self.mImgSelectPicture.addConstraint(mNSLayoutConstraint!)
        
    }
    
    private func publishPhoto() {
         
         let description = mFieldPhotoDescription.text ?? ""
         
         if(!mPhotoSelected) {
             makeAlert(message: "Você precisa selecionar uma foto antes de salvar")
             return
         }
         
         self.mHud.show(in: self.view)
                 
         self.mPhotoDict["text"] = description
         self.mPhotoDict["picture_width"] = mPostImgWidth
         self.mPhotoDict["picture_height"] = mPostImageHeight
         self.mPhotoDict["embassy_id"] = mUser.embassy_id
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
                 
                 self.mPhotoDict["picture"] = downloadURL.absoluteString
                 
                 self.mDocumentReference = self.mDatabase
                     .collection(MyFirebaseCollections.EMBASSY_PHOTOS)
                     .addDocument(data: self.mPhotoDict, completion: { (error) in
                         if error == nil {
                             self.mDocumentReference.updateData(["id": self.mDocumentReference.documentID])
                             self.delegate.onCreatePhoto(vc: self)
                             self.mHud.dismiss()
                             self.navigationController?.popViewController(animated: true)
                         }
                     })
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
