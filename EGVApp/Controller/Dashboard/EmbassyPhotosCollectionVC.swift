//
//  EmbassyPhotosCollectionVC.swift
//  EGVApp
//
//  Created by Fabricio on 27/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import INSPhotoGallery
import FirebaseFirestore

private let reuseIdentifier = "Cell"

class EmbassyPhotosCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    lazy var mEmbassyPhotoList: [INSPhotoViewable] = {
        return []
    }()
    
    var mUser: User!
    var mEmbassyID: String!
    var mDatabase: Firestore!
    var useCustomOverlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        self.mDatabase = MyFirebase.sharedInstance.database()
        getPhotoList()
        

        // Do any additional setup after loading the view.
    }
    
    private func getPhotoList() {
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
                                }
                            }
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
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
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
        let cell = collectionView.cellForItem(at: indexPath) as! EmbassyPhotoCollectionCell
        let currentPhoto = mEmbassyPhotoList[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: mEmbassyPhotoList, initialPhoto: currentPhoto, referenceView: cell)
        if useCustomOverlay {
            galleryPreview.overlayView = INSPhotosOverlayView(frame: CGRect.zero)
        }
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.mEmbassyPhotoList.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? EmbassyPhotoCollectionCell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
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
