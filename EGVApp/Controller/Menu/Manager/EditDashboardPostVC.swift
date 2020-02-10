//
//  EditDashboardPostVC.swift
//  EGVApp
//
//  Created by Fabricio on 23/01/20.
//  Copyright © 2020 Fabrício Augusto. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import SkyFloatingLabelTextField
import FontAwesome_swift
import FirebaseFirestore
import FirebaseStorage
import YPImagePicker
import KMPlaceholderTextView
import JGProgressHUD



class EditDashboardPostVC: UIViewController {

    
    @IBOutlet weak var mSvFormFields: UIStackView!
    
    @IBOutlet weak var mImgSelectPicture: UIImageView!
    @IBOutlet weak var mPostDescriptionField: KMPlaceholderTextView!
    @IBOutlet weak var mBtSelectPicture: UIButton!
    @IBOutlet weak var mUpdateDashboardPost: UIBarButtonItem!

    var mUser: User!
    var mPost: Post!
    private var mPostDict: [String: Any] = [:]
    private var mStorage: Storage!
    private var mDatabase: Firestore!
    private var mTitleField: SkyFloatingLabelTextField!
    private var mActionButtonField: SkyFloatingLabelTextField!
    private var mLinkField: SkyFloatingLabelTextField!
    private var mPhotoSelected: Bool = false
    private var mPostImgWidth: Int = 0
    private var mPostImageHeight: Int = 0
    private var mImageData: Data?
    private var mImageMetaData: StorageMetadata?
    private var imgExtension: String = ""
    private var tempImagePath: URL?
    private var mNSLayoutConstraint: NSLayoutConstraint?
    private var mHud: JGProgressHUD!
    private var mDocumentReference: DocumentReference!
    private var mkeyboardWillShowObserver: NSObjectProtocol!
    private var mkeyboardWillHideObserver: NSObjectProtocol!
    private var mTabBarHeight: CGFloat = 0
    private var mCurrentKeyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mDatabase = MyFirebase.sharedInstance.database()
        mStorage = MyFirebase.sharedInstance.storage()
        
        self.addFields()
        
        let onTapSelectPicture = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.onTapSelectPicture))
        mImgSelectPicture.isUserInteractionEnabled = true
        mImgSelectPicture.addGestureRecognizer(onTapSelectPicture)
        
        self.setImageViewSize(aspectWith: 4, aspectHeight: 3)
        
        
        let manageEventsImage = UIImage(named: "icon_picture")
        let manageEventsTintedImage = manageEventsImage?.withRenderingMode(.alwaysTemplate)
        mBtSelectPicture.setImage(manageEventsTintedImage, for: .normal)
        mBtSelectPicture.tintColor = AppColors.colorWhite
        mBtSelectPicture.imageView?.contentMode = .scaleAspectFit
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Publicando..."
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func onClickBtStartGalleryVC(_ sender: UIButton) {
        startGalleryPicker()
    }
    
    @IBAction func onClickBtUpdateDashboardPost(_ sender: UIBarButtonItem) {
        publishPostPhoto()
    }
    
    private func addFields() {
        
        self.mTitleField = buildTextField(placeholder: "Título", icon: String.fontAwesomeIcon(name: .heading))
        mSvFormFields.insertArrangedSubview(self.mTitleField, at: 1)
        self.mTitleField.delegate = self
        
        self.mActionButtonField = buildTextField(placeholder: "Texto do Botão de Ação (Opcional)", icon: String.fontAwesomeIcon(name: .externalLinkSquareAlt))
        mSvFormFields.insertArrangedSubview(self.mActionButtonField, at: 2)
        self.mActionButtonField.delegate = self
        
        self.mLinkField = buildTextField(placeholder: "Link (Opcional)", icon: String.fontAwesomeIcon(name: .link))
        mSvFormFields.insertArrangedSubview(self.mLinkField, at: 3)
        self.mLinkField.delegate = self
        
        self.mPostDescriptionField.delegate = self
        
        //AppLayout.addLineToView(view: mBiographyContainer, position: .LINE_POSITION_BOTTOM, color: AppColors.colorGrey, width: 1.0)
        
        //mTitleField.delegate = self
        //mLinkField.delegate = self
        mSvFormFields.alignment = .fill
        mSvFormFields.distribution = .fill
        mSvFormFields.axis = .vertical
        mSvFormFields.spacing = 24
        
        self.bindData()
        
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
    
    private func bindData() {
       
        self.mDatabase
        .collection("app_private_content")
        .document("post_dashboard")
            .getDocument { (documentSnapshot, error) in
                if let post = documentSnapshot.flatMap({
                    $0.data().flatMap({ (data) in
                        return Post(dictionary: data)
                    })
                }) {
                    
                    self.mPost = post
                    
                    self.mTitleField.text = post.title
                    self.mActionButtonField.text = post.action_button_text ?? ""
                    self.mLinkField.text = post.link ?? ""
                    self.mPostDescriptionField.text = post.text ?? ""
                    
                    if let post_picture = post.picture {
                                                
                        let url = URL(string: post_picture)
                        
                        if url != nil {
                            
                            self.setImageViewSize(aspectWith: post.picture_width, aspectHeight: post.picture_height)
                            
                            self.mImgSelectPicture.isHidden = false
                            
                            // kf
                            OperationQueue.main.addOperation {
                                self.mImgSelectPicture.kf.setImage(
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
    
    private func startGalleryPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
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
                self.mImgSelectPicture.isHidden = false
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
    
    private func publishPostPhoto() {
         
         let title = mTitleField.text ?? ""
         let link = mLinkField.text ?? ""
         let description = mPostDescriptionField.text ?? ""
         let action_button_text = mActionButtonField.text ?? ""
        
         
         if(description.isEmpty) {
             makeAlert(message: "A foto precisa ter um texto de descrição")
             return
         }
        
        if(!link.isEmpty || !action_button_text.isEmpty) {
            
            if(link.isEmpty) {
                makeAlert(message: "Como o Botão de Ação está preenchido, você deve também inserir um link para o botão")
                return
            }
            
            if(action_button_text.isEmpty) {
                makeAlert(message: "Como o Link está preenchido, você deve também inserir um texto para o botão de ação")
                return
            }
             
         }
         
         self.mHud.show(in: self.view)
        
         self.mPostDict["id"] = "post_dashboard"
         self.mPostDict["type"] = "post_picture"
         self.mPostDict["user_id"] = mUser.id
         self.mPostDict["user"] = mUser.toBasicMap()
         self.mPostDict["title"] = title
         self.mPostDict["link"] = link
         self.mPostDict["text"] = description
         self.mPostDict["action_button_text"] = action_button_text
         self.mPostDict["date"] = FieldValue.serverTimestamp()
         
        if(mPhotoSelected) {
        
            self.mPostDict["picture_width"] = mPostImgWidth
            self.mPostDict["picture_height"] = mPostImageHeight
            
            uploadToStorage()
        } else {
            self.mPostDict["picture_width"] = mPost.picture_width
            self.mPostDict["picture_height"] = mPost.picture_height
            self.mPostDict["picture"] = mPost.picture
            
            self.mDatabase
                .collection("app_private_content")
                .document("post_dashboard")
                .setData(self.mPostDict, completion: { (error) in
                    if error == nil {
                        self.mHud.dismiss()
                        self.navigationController?.popViewController(animated: true)
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
                 
                 self.mDatabase
                     .collection("app_private_content")
                     .document("post_dashboard")
                     .setData(self.mPostDict, completion: { (error) in
                         if error == nil {
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

extension EditDashboardPostVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 200
    }
}

extension EditDashboardPostVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
