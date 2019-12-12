//
//  CreatePostVC.swift
//  EGVApp
//
//  Created by Fabricio on 06/12/19.
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


protocol CreatePostDelegate: class {
    func postWasPublished(vc: CreatePostVC)
}

class CreatePostVC: UIViewController, TextEditorDelegate {
    
    @IBOutlet weak var mLbWriteText: UILabel!
    @IBOutlet weak var mImgSelectPicture: UIImageView!
    @IBOutlet weak var mFieldNoteTitle: UITextField!
    @IBOutlet weak var mFieldPhotoDescription: KMPlaceholderTextView!
    
    weak var delegate: RootPostsTableVC?
    
    var mUser: User!
    var mPostType: String!
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
        
        
        if(mPostType == "photo") {
            mFieldNoteTitle.isHidden = true
            mLbWriteText.isHidden = true
        }
        
        if(mPostType == "thought") {
            mImgSelectPicture.isHidden = true
            mFieldNoteTitle.isHidden = true
            mFieldPhotoDescription.isHidden = true
        }
        
        if(mPostType == "note") {
            mFieldPhotoDescription.isHidden = true
            mLbWriteText.text = "Corpo da nota"
        }
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Publicando..."
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBtPublishPost(_ sender: UIBarButtonItem) {
        if(mPostType == "photo") {
            self.publishPostPhoto()
        }
        
        if(mPostType == "note") {
            self.publishPostNote()
        }
        
        if(mPostType == "thought") {
            self.publishPostThought()
        }
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
        
        if(mPostType == "thought") {
            textSize = "24"
        }
        
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
    
    private func publishPostThought() {
        
        let body = mPostHtmlText
                
        if(body.isEmpty) {
            makeAlert(message: "Escreva um texto para o pensamento")
            return
        }
        
        self.mHud.show(in: self.view)
                
        self.mPostDict["type"] = "thought"
        self.mPostDict["user_id"] = mUser.id
        self.mPostDict["user"] = mUser.toBasicMap()
        self.mPostDict["text"] = body
        self.mPostDict["post_comments"] = 0
        self.mPostDict["post_likes"] = 0
        self.mPostDict["embassy_id"] = mUser.embassy_id
        self.mPostDict["user_verified"] = mUser.verified
        self.mPostDict["date"] = FieldValue.serverTimestamp()
        
        self.mDocumentReference = self.mDatabase
        .collection(MyFirebaseCollections.POSTS)
        .addDocument(data: self.mPostDict, completion: { (error) in
            if let error = error {
                
            } else {
                self.mDocumentReference.updateData(["id": self.mDocumentReference.documentID])
                self.delegate?.postWasPublished(vc: self)
                self.mHud.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    private func publishPostNote() {
        
        let title = mFieldNoteTitle.text ?? ""
        let body = mPostHtmlText
        
        if(!mPhotoSelected) {
            makeAlert(message: "Você precisa selecionar uma foto para o post")
            return
        }
        
        if(title.isEmpty) {
            makeAlert(message: "Você precisa inserir um título na nota")
            return
        }
        
        if(body.isEmpty) {
            makeAlert(message: "Escreva um texto para a nota")
            return
        }
        
        self.mHud.show(in: self.view)
                
        self.mPostDict["type"] = "note"
        self.mPostDict["user_id"] = mUser.id
        self.mPostDict["user"] = mUser.toBasicMap()
        self.mPostDict["title"] = title
        self.mPostDict["text"] = body
        self.mPostDict["post_comments"] = 0
        self.mPostDict["post_likes"] = 0
        self.mPostDict["picture_width"] = mPostImgWidth
        self.mPostDict["picture_height"] = mPostImageHeight
        self.mPostDict["embassy_id"] = mUser.embassy_id
        self.mPostDict["user_verified"] = mUser.verified
        self.mPostDict["date"] = FieldValue.serverTimestamp()
        uploadToStorage()
        
    }
    
    private func publishPostPhoto() {
        
        let description = mFieldPhotoDescription.text ?? ""
        
        if(!mPhotoSelected) {
            makeAlert(message: "Você precisa selecionar uma foto para o post")
            return
        }
        
        if(description.isEmpty) {
            makeAlert(message: "A foto precisa ter um texto de descrição")
            return
        }
        
        self.mHud.show(in: self.view)
                
        self.mPostDict["type"] = "post"
        self.mPostDict["user_id"] = mUser.id
        self.mPostDict["user"] = mUser.toBasicMap()
        self.mPostDict["text"] = description
        self.mPostDict["post_comments"] = 0
        self.mPostDict["post_likes"] = 0
        self.mPostDict["picture_width"] = mPostImgWidth
        self.mPostDict["picture_height"] = mPostImageHeight
        self.mPostDict["embassy_id"] = mUser.embassy_id
        self.mPostDict["user_verified"] = mUser.verified
        self.mPostDict["date"] = FieldValue.serverTimestamp()
        uploadToStorage()
        
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
                    .collection(MyFirebaseCollections.POSTS)
                    .addDocument(data: self.mPostDict, completion: { (error) in
                        if let error = error {
                            
                        } else {
                            self.mDocumentReference.updateData(["id": self.mDocumentReference.documentID])
                            self.delegate?.postWasPublished(vc: self)
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

}

