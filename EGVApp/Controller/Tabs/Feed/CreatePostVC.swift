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
import Gallery
import AVKit


protocol CreatePostDelegate: class {
    func postWasPublished(vc: CreatePostVC, highlightPost: Bool)
}

class CreatePostVC: UIViewController {
    
    
    //@IBOutlet weak var mViewWriteTextContainer: UIView!
    //@IBOutlet weak var mLbWriteText: UILabel!
    
    @IBOutlet weak var mImgSelectPicture: UIImageView!
    @IBOutlet weak var mViewSelectedVideo: UIView!
    //@IBOutlet weak var mFieldNoteTitle: UITextField!
    @IBOutlet weak var mImgProfileUser: UIImageView!
    
    @IBOutlet weak var mLbProfileName: UILabel!
    @IBOutlet weak var mFieldPhotoDescription: KMPlaceholderTextView!
    @IBOutlet weak var mBtSelectVideo: UIButton!
    @IBOutlet weak var mBtSelectPicture: UIButton!
   // @IBOutlet weak var mConstraintWriteTextMarginBottom: NSLayoutConstraint!
    @IBOutlet weak var mPublishHighlightsContainer: UIStackView!
    @IBOutlet weak var mHighlightSwitch: UISwitch!
    
    @IBOutlet weak var mViewPublishHighlightsContainer: UIView!
    
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
    private var mPlayer: AVPlayer!
    private var mPlayerController: AVPlayerViewController!
    private var mCurrentKeyboardHeight: CGFloat = 0.0
    private var mkeyboardWillShowObserver: NSObjectProtocol!
    private var mkeyboardWillHideObserver: NSObjectProtocol!
    private var mTabBarHeight: CGFloat = 0
    
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
        
        self.bindData()
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.tapFunction))
        //mLbWriteText.isUserInteractionEnabled = true
        //mLbWriteText.addGestureRecognizer(tap)
        
        let onTapSelectPicture = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.onTapSelectPicture))
        mImgSelectPicture.isUserInteractionEnabled = true
        mImgSelectPicture.addGestureRecognizer(onTapSelectPicture)
        
        self.setImageViewSize(aspectWith: 4, aspectHeight: 3)
        
        
        let manageEventsImage = UIImage(named: "icon_picture")
        let manageEventsTintedImage = manageEventsImage?.withRenderingMode(.alwaysTemplate)
        mBtSelectPicture.setImage(manageEventsTintedImage, for: .normal)
        mBtSelectPicture.tintColor = AppColors.colorText
        mBtSelectPicture.imageView?.contentMode = .scaleAspectFit
        AppLayout.addLineToView(view: mBtSelectPicture, position: .LINE_POSITION_BOTTOM, color: AppColors.colorGrey, width: 1.0)
        AppLayout.addLineToView(view: mBtSelectPicture, position: .LINE_POSITION_TOP, color: AppColors.colorGrey, width: 1.0)
        
        let selectVideosIcon = UIImage(named: "icon_menu_film")
        let selectVideosTintedIcon = selectVideosIcon?.withRenderingMode(.alwaysTemplate)
        mBtSelectVideo.setImage(selectVideosTintedIcon, for: .normal)
        mBtSelectVideo.tintColor = AppColors.colorSubText
        mBtSelectVideo.imageView?.contentMode = .scaleAspectFit
        AppLayout.addLineToView(view: mBtSelectVideo, position: .LINE_POSITION_BOTTOM, color: AppColors.colorGrey, width: 1.0)
        
        mHud = JGProgressHUD(style: .extraLight)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Publicando..."
        
        mFieldPhotoDescription.delegate = self
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        mHighlightSwitch.isOn = false
        
        if(mUser.committee_leader) {
            mPublishHighlightsContainer.isHidden = false
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func onClickBtPublishPost(_ sender: UIBarButtonItem) {
        
        if self.mPhotoSelected {
            self.publishPostPhoto()
        } else {
            self.publishPostThought()
        }
    }
    
    
    @IBAction func onClickSelectPicture(_ sender: UIButton) {
        self.startPhotoGalleryPicker()
    }
    
    @IBAction func onClickSelectVideo(_ sender: UIButton) {
        //self.startVideoGalleryPicker()
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "textEditorSegue", sender: nil)
    }
    
    @objc func onTapSelectPicture(sender:UITapGestureRecognizer) {
        self.startPhotoGalleryPicker()
    }
    
    /*func editTextDone(text: String, vc: TextEditorVC) {
        
        self.mPostHtmlText = text
        var textSize: String = "16"
        
        if(mPostType == "thought") {
            textSize = "24"
        }
        
        mConstraintWriteTextMarginBottom.constant = 0
        
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
    }*/
    
    private func bindData() {
        
        if(mUser.committee_leader) {
            mViewPublishHighlightsContainer.isHidden = false
        }
        
        self.mLbProfileName.text = mUser.name
        
        mImgProfileUser.layer.cornerRadius = 15
        mImgProfileUser.layer.masksToBounds = true
        
        mImgProfileUser.kf.indicatorType = .activity
        if let profile_img = mUser.profile_img {
            let url = URL(string: profile_img)
            mImgProfileUser.kf.setImage(
                with: url,
                placeholder: UIImage(named: "grey_circle"),
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
        }
    }
    
    private func preparePlayer(videoURL: String) {
        let url: URL = URL(fileURLWithPath: videoURL)
        self.mPlayer = AVPlayer(url: url)
        self.mPlayerController = AVPlayerViewController()
        mPlayerController.player = mPlayer
        mPlayerController.showsPlaybackControls = true
        mPlayerController.player?.play()
        mPlayerController.view.frame = mViewSelectedVideo.bounds
        mViewSelectedVideo.addSubview(mPlayerController.view)
        mViewSelectedVideo.isHidden = false
    }
    
    private func startPhotoGalleryPicker() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.library.mediaType = .photo
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
                self.mFieldPhotoDescription.placeholder = "Escreva algo sobre esta foto"
                self.mImgSelectPicture.isHidden = false
                self.mImgSelectPicture.image = photo.image
                self.setImageViewSize(aspectWith: self.mPostImgWidth, aspectHeight: self.mPostImageHeight)
            }
            
        }
        self.present(picker, animated: true, completion: nil)

    }
    
    private func startVideoGalleryPicker() {
        
        let gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = [.videoTab]
        present(gallery, animated: true, completion: nil)
        
        /*var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.library.mediaType = .video
        config.library.onlySquare = true
        config.showsCrop = .none
        config.video.libraryTimeLimit = TimeInterval(300)
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
            
            if let video = items.singleVideo {
                print(video.fromCamera)
                print(video.thumbnail)
                print(video.url)
                picker.dismiss(animated: true, completion: nil)
                self.preparePlayer(videoURL: video.url.absoluteString)
                
                /*self.uploadTOFireBaseVideo(url: video.url, success: { (video_url) in
                    
                }) { (error) in
                    print(error)
                }*/
            }
            
        }
        self.present(picker, animated: true, completion: nil)*/

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
            //vc.delegate = self
        }
    }
    
    private func publishPostThought() {
        
        let body = mFieldPhotoDescription.text ?? ""
        var post_verified: Bool = false
                
        if(body.isEmpty) {
            makeAlert(message: "Você precisa escrever algo antes de publicar")
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
        
        if(mHighlightSwitch.isOn) {
            self.mPostDict["user_verified"] = true
        }
        
        if(mUser.influencer || mUser.counselor) {
            self.mPostDict["user_verified"] = true
        }
        
        post_verified = self.mPostDict["user_verified"] as! Bool
        
        self.mDocumentReference = self.mDatabase
        .collection(MyFirebaseCollections.POSTS)
        .addDocument(data: self.mPostDict, completion: { (error) in
            if let error = error {
                
            } else {
                self.mDocumentReference.updateData(["id": self.mDocumentReference.documentID])
                self.delegate?.postWasPublished(vc: self, highlightPost: post_verified)
                self.mHud.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    /*private func publishPostNote() {
        
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
        
        if(mHighlightSwitch.isOn) {
            self.mPostDict["user_verified"] = true
        }
        
        if(mUser.influencer) {
            self.mPostDict["user_verified"] = true
        }
        
        uploadToStorage()
        
    }*/
    
    private func publishPostPhoto() {
        
        let description = mFieldPhotoDescription.text ?? ""
        var post_verified: Bool = false
        
        if(description.isEmpty) {
            makeAlert(message: "Você precisa escrever uma descrição para a foto")
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
        
        if(mHighlightSwitch.isOn) {
            self.mPostDict["user_verified"] = true
        }
        
        if(mUser.influencer) {
            self.mPostDict["user_verified"] = true
        }
        
        post_verified = self.mPostDict["user_verified"] as! Bool
        
        uploadToStorage(post_verified: post_verified)
        
    }
   
    private func uploadToStorage(post_verified: Bool) {
        
        
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
                            self.delegate?.postWasPublished(vc: self, highlightPost: post_verified)
                            self.mHud.dismiss()
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
              }
            }
        }
    }
    
    func uploadTOFireBaseVideo(url: URL, success : @escaping (String) -> Void, failure : @escaping (Error) -> Void) {

        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let path = NSTemporaryDirectory() + name

        let dispatchgroup = DispatchGroup()

        dispatchgroup.enter()

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputurl = documentsURL.appendingPathComponent(name)
        var ur = outputurl
        self.convertVideo(toMPEG4FormatForVideo: url as URL, outputURL: outputurl) { (session) in

            ur = session.outputURL!
            dispatchgroup.leave()

        }
        dispatchgroup.wait()

        let data = NSData(contentsOf: ur as URL)

        do {

            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)

        } catch {

            print(error)
        }

        let storageRef = Storage.storage().reference().child("videos/post").child(name)
        if let uploadData = data as Data? {
            storageRef.putData(uploadData, metadata: nil
                , completion: { (metadata, error) in
                    if let error = error {
                        failure(error)
                    }else{
                        
                        storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                          // Uh-oh, an error occurred!
                          return
                        }

                        let strPic:String = downloadURL.absoluteString
                        print(strPic)
                        success(strPic)
                        }
                    }
            })
        }
    }
    
    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        //try! FileManager.default.removeItem(at: outputURL as URL)
        let asset = AVURLAsset(url: inputURL as URL, options: nil)

        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension CreatePostVC: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
        
        let editor = VideoEditor()
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
          DispatchQueue.main.async {
            if let tempPath = tempPath {
                print(tempPath)
                self.preparePlayer(videoURL: tempPath.absoluteString)
            }
          }
        }
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        
    }
    
    
}

extension CreatePostVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }*/
}
