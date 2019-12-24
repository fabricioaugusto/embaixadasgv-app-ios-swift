//
//  ManagePhotosCollectionVC.swift
//  EGVApp
//
//  Created by Fabricio on 11/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import INSPhotoGallery
import FirebaseFirestore
import JGProgressHUD

private let reuseIdentifier = "Cell"

class ManagePhotosCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, CreatePhotoDelegate {
    
    lazy var mEmbassyPhotoList: [INSPhotoViewable] = {
        return []
    }()
    
    private var mPhotoListIDs: [String] = []
    private var mSelectedPhotoID: String!
    
    var mUser: User!
    var mEmbassyID: String!
    var mDatabase: Firestore!
    var useCustomOverlay = false
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Excluindo..."
        
        self.mDatabase = MyFirebase.sharedInstance.database()
        getPhotoList()

        // Do any additional setup after loading the view.
    }

    private func getPhotoList() {
        
        self.mEmbassyPhotoList.removeAll()
        self.mPhotoListIDs.removeAll()
        
        self.mDatabase.collection(MyFirebaseCollections.EMBASSY_PHOTOS)
            .whereField("embassy_id", isEqualTo: mEmbassyID ?? "")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    
                } else {
                    if let query = querySnapshot {
                        
                        if(query.documents.count > 0) {
                            for document in query.documents {
                                if let embassyPhoto = EmbassyPhoto(dictionary: document.data()) {
                                    let insphoto = INSPhoto(imageURL: URL(string: embassyPhoto.picture), thumbnailImageURL: URL(string: embassyPhoto.picture))
                                    self.mEmbassyPhotoList.append(insphoto)
                                    self.mPhotoListIDs.append(document.documentID)
                                }
                            }
                            self.mHud.dismiss()
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
        }
    }
    
    private func alertDeletePhoto() {
        
        let alert = UIAlertController(title: "Excluir Foto", message: "Tem certeza que deseja excluir esta foto?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sim, tenho certeza", style: UIAlertAction.Style.destructive, handler: { (alertAction) in
            self.deletePhoto()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func deletePhoto() {
        
        self.mHud.show(in: self.view)
        
        mDatabase.collection(MyFirebaseCollections.EMBASSY_PHOTOS)
            .document(self.mSelectedPhotoID)
            .delete { (error) in
                if error == nil {
                    self.getPhotoList()
                }
        }
    }
    
    func onCreatePhoto(vc: CreatePhotoVC) {
        self.getPhotoList()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "createPhotoSegue") {
            let vc = segue.destination as! CreatePhotoVC
            vc.delegate = self
            vc.mUser = self.mUser
        }
    }
    

    // MARK: UICollectionViewDataSource
    
    

    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let totalHeight: CGFloat = (self.view.frame.width / 3)
        let totalWidth: CGFloat = (self.view.frame.width / 3)
        
        
        return CGSize(width: totalWidth, height: totalHeight)
    }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth: CGFloat = (self.view.frame.width / 3)
        
        
        return CGSize(width: totalWidth, height: totalWidth)
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "embassyPhotoCollectionCell", for: indexPath) as! EmbassyPhotoCollectionCell
        cell.populateWithPhoto(mEmbassyPhotoList[(indexPath as NSIndexPath).row])
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mEmbassyPhotoList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        self.mSelectedPhotoID = mPhotoListIDs[indexPath.row]
        
        let alert = UIAlertController(title: "Seleciona uma opção", message: "O que você deseja fazer?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Visualizar", style: .default , handler:{ (UIAlertAction)in
            
            let cell = collectionView.cellForItem(at: indexPath) as! EmbassyPhotoCollectionCell
            let currentPhoto = self.mEmbassyPhotoList[(indexPath as NSIndexPath).row]
            let galleryPreview = INSPhotosViewController(photos: self.mEmbassyPhotoList, initialPhoto: currentPhoto, referenceView: cell)
            if self.useCustomOverlay {
                galleryPreview.overlayView = INSPhotosOverlayView(frame: CGRect.zero)
            }
            
            galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                if let index = self?.mEmbassyPhotoList.firstIndex(where: {$0 === photo}) {
                    let indexPath = IndexPath(item: index, section: 0)
                    return collectionView.cellForItem(at: indexPath) as? EmbassyPhotoCollectionCell
                }
                return nil
            }
            self.present(galleryPreview, animated: true, completion: nil)
        }))
        /*alert.addAction(UIAlertAction(title: "Editar", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
        }))*/
        alert.addAction(UIAlertAction(title: "Deletar", style: .destructive , handler:{ (UIAlertAction)in
            self.alertDeletePhoto()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
