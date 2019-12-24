//
//  CreateNotificationVC.swift
//  EGVApp
//
//  Created by Fabricio on 20/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import RichEditorView
import FirebaseFirestore
import FirebaseStorage
import YPImagePicker
import SwiftHash
import JGProgressHUD
import KMPlaceholderTextView

class CreateNotificationVC: UIViewController, TextEditorDelegate {

    @IBOutlet weak var mLbWriteText: UILabel!
     @IBOutlet weak var mImgSelectPicture: UIImageView!
     @IBOutlet weak var mFieldNoteTitle: UITextField!
     @IBOutlet weak var mFieldNoteDescription: UITextField!
     
     weak var delegate: RootPostsTableVC?
     
     var mUser: User!
     private var mPostDict: [String: Any] = [:]
     private var mPostHtmlText: String = ""
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
     
     lazy var toolbar: RichEditorToolbar = {
         let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
         toolbar.options = [RichEditorDefaultOption.bold, RichEditorDefaultOption.italic,
             RichEditorDefaultOption.link,
             RichEditorDefaultOption.undo,
             RichEditorDefaultOption.redo,
             RichEditorDefaultOption.clear]
         return toolbar
     }()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         mDatabase = MyFirebase.sharedInstance.database()
         mStorage = MyFirebase.sharedInstance.storage()
         
         let tap = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.tapFunction))
         mLbWriteText.isUserInteractionEnabled = true
         mLbWriteText.addGestureRecognizer(tap)
         
         let onTapSelectPicture = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.onTapSelectPicture))
         mImgSelectPicture.isUserInteractionEnabled = true
         mImgSelectPicture.addGestureRecognizer(onTapSelectPicture)
         
         self.setImageViewSize(aspectWith: 4, aspectHeight: 3)

         
         mHud = JGProgressHUD(style: .extraLight)
         mHud.textLabel.textColor = AppColors.colorPrimary
         mHud.indicatorView?.tintColor = AppColors.colorLink
         mHud.textLabel.text = "Enviando..."
         
         // Do any additional setup after loading the view.
     }
     
     @IBAction func onClickBtPublishNotification(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Seleciona uma opção", message: "Para quem você deseja enviar a notificação?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Todos", style: .default , handler:{ (UIAlertAction)in
            self.publishPostNote(to: "all")
        }))
        alert.addAction(UIAlertAction(title: "Somente Líderes", style: .default , handler:{ (UIAlertAction)in
            self.publishPostNote(to: "leaders")
        }))
        alert.addAction(UIAlertAction(title: "Usuários iOS", style: .default , handler:{ (UIAlertAction)in
            self.publishPostNote(to: "ios_users")
        }))
        alert.addAction(UIAlertAction(title: "Usuários Android", style: .default , handler:{ (UIAlertAction)in
            self.publishPostNote(to: "android_users")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    
     }
     
     
     @objc func tapFunction(sender:UITapGestureRecognizer) {
         performSegue(withIdentifier: "textEditorSegue", sender: nil)
     }
     
     @objc func onTapSelectPicture(sender:UITapGestureRecognizer) {
         self.startGalleryPicker()
     }
     
     func editTextDone(text: String, vc: TextEditorVC) {
         
         self.mPostHtmlText = text
         var textSize: String = "16"
         
         let bodyHTML = "<span style='font-family: \"-apple-system\", \"HelveticaNeue\" ; font-size:\(textSize);  color:#4D4D4F'; padding: 0; margin: 0;>\(text)</span>"
         
         if let htmldata = bodyHTML.data(using: String.Encoding.isoLatin1), let attributedString = try? NSAttributedString(data: htmldata, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
             mLbWriteText.attributedText = attributedString
             //print(finalString)
             //output: test北京的test
         }
         
         
         /*let data = Data(bodyHTML.utf8)
         if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
             mLbWriteText.attributedText = attributedString
         }*/
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
     
     // MARK
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if(segue.identifier == "textEditorSegue") {
             let vc = segue.destination as! TextEditorVC
             vc.previousText = self.mPostHtmlText
             vc.delegate = self
         }
     }
     
    private func publishPostNote(to segment: String) {
         
        let title = mFieldNoteTitle.text ?? ""
        let description = mFieldNoteDescription.text ?? ""
        let text = mPostHtmlText

        if(title.isEmpty || text.isEmpty || description.isEmpty) {
            makeAlert(message: "Você deve preencher todos os campos")
            return
        }
         
         self.mHud.show(in: self.view)
                
        if segment == "all" {
            self.mPostDict["type"] = "manager_notification"
            self.mPostDict["only_leaders"] = false
            self.mPostDict["to_topic"] = "egv_topic_members"
        }
        
        if segment == "leaders" {
            self.mPostDict["type"] = "manager_notification"
            self.mPostDict["only_leaders"] = true
            self.mPostDict["to_topic"] = "egv_topic_leaders"
        }
        
        if segment == "ios_users" {
            self.mPostDict["type"] = "ios_users"
            self.mPostDict["only_leaders"] = false
            self.mPostDict["to_topic"] = "egv_topic_ios"
        }
        
        if segment == "android_users" {
            self.mPostDict["type"] = "android_users"
            self.mPostDict["only_leaders"] = false
            self.mPostDict["to_topic"] = "egv_topic_android"
        }
         
         self.mPostDict["title"] = title
         self.mPostDict["description"] = description
         self.mPostDict["text"] = text
         self.mPostDict["picture"] = "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/images%2Fpost%2Farticle%2F7bbf647d-817d-4022-9286-06778c018e40.jpg?alt=media&token=b05e843c-091d-496e-8e24-8e0fb209e330"
         self.mPostDict["receiver_id"] = ""
         self.mPostDict["created_at"] = FieldValue.serverTimestamp()
        
        if mPhotoSelected {
            uploadToStorage()
        } else {
            self.mDocumentReference = self.mDatabase
            .collection(MyFirebaseCollections.NOTIFICATIONS)
            .addDocument(data: self.mPostDict, completion: { (error) in
                if let error = error {
                    
                } else {
                    self.mHud.dismiss()
        
                    let alert = UIAlertController(title: "Notificação Enviada", message: "A notificação foi enviada com sucesso!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alertAction) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
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
                 
                 self.mPostDict["picture"] = downloadURL.absoluteString
                 
                 self.mDocumentReference = self.mDatabase
                     .collection(MyFirebaseCollections.NOTIFICATIONS)
                     .addDocument(data: self.mPostDict, completion: { (error) in
                         if let error = error {
                             
                         } else {
                             self.mHud.dismiss()
                             
                             let alert = UIAlertController(title: "Notificação enviada", message: "A notificação foi enviada com sucesso!", preferredStyle: UIAlertController.Style.alert)
                             alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alertAction) in
                                 self.navigationController?.popViewController(animated: true)
                             }))
                             self.present(alert, animated: true, completion: nil)
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

}
