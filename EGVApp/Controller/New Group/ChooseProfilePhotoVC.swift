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

class ChooseProfilePhotoVC: UIViewController {

    
    @IBOutlet weak var mImgUserProfile: UIImageView!
    
    var mUser: User!
    var tempImagePath: URL?
    var mImageData: Data?
    var imgExtension: String = ""
    var mStorage: Storage!
    var mDatabase: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mStorage = MyFirebase.sharedInstance.storage()
        mDatabase = MyFirebase.sharedInstance.database()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtChoosePhoto(_ sender: UIButton) {
        startGalleryPicker()
    }
    
    
    
    private func startGalleryPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
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
                if self.imgExtension == "png"{
                    let imageData = photo.image.pngData()
                    try! imageData?.write(to: imagePath!)
                } else {
                    let imageData: Data? = photo.image.jpegData(compressionQuality: 0.70)
                    try! imageData?.write(to: imagePath!)
                }
                self.tempImagePath = imagePath!
                self.ivPostImg.image = photo.image
            }
            
            
        }
        self.present(picker, animated: true, completion: nil)

    }
    
    private func uploadToStoge() {
        // Data in memory
        if let data = mImageData {
            // Create a reference to the file you want to upload
            let riversRef = mStorage.reference().child("images/rivers.jpg")

            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putData(data, metadata: nil)
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
    
                self.mDatabase
                    .collection(MyFirebaseCollections.USERS)
                    .document(self.mUser.id)
                    .updateData(["profile_img" : downloadURL.absoluteString]) { (err) in
                        if let err = err {
                            
                        } else {
                            //Doc Updated
                        }
                }
              }
            }
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
