//
//  EmbassyPhotosVC.swift
//  EGVApp
//
//  Created by Fabricio on 27/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import INSPhotoGallery

class EmbassyPhotosVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var useCustomOverlay = false
    
    lazy var photos: [INSPhotoViewable] = {
        return [
            INSPhoto(imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/images%2Fembassy%2Fpicture%2F0ebca32b-ad4f-49b8-82dc-b57c8100673f.jpg?alt=media&token=b4a148c2-6ed3-4b78-adea-4ecb16a6747b"), thumbnailImageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/images%2Fembassy%2Fpicture%2F0ebca32b-ad4f-49b8-82dc-b57c8100673f.jpg?alt=media&token=b4a148c2-6ed3-4b78-adea-4ecb16a6747b")),
            INSPhoto(imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/images%2Fembassy%2Fpicture%2F2d4c115b-7a55-4072-b6ac-dabdbb2e0876.jpg?alt=media&token=217ae28a-4e93-42b1-bdae-cdab513fa311"), thumbnailImageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/images%2Fembassy%2Fpicture%2F2d4c115b-7a55-4072-b6ac-dabdbb2e0876.jpg?alt=media&token=217ae28a-4e93-42b1-bdae-cdab513fa311")),
            INSPhoto(imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/images%2Fembassy%2Fpicture%2F39e48bd0-ec47-4f93-b53d-9e77c01e7ff3.jpg?alt=media&token=f294a724-0073-4f9b-b686-6d0618a96810"), thumbnailImageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/egv-app-f851e.appspot.com/o/images%2Fembassy%2Fpicture%2F39e48bd0-ec47-4f93-b53d-9e77c01e7ff3.jpg?alt=media&token=f294a724-0073-4f9b-b686-6d0618a96810"))
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        for photo in photos {
            if let photo = photo as? INSPhoto {
                #if swift(>=4.0)
                photo.attributedTitle = NSAttributedString(string: "Example caption text\ncaption text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                #else
                photo.attributedTitle = NSAttributedString(string: "Example caption text\ncaption text", attributes: [NSForegroundColorAttributeName: UIColor.white])
                #endif
            }
        }
    }
}

extension EmbassyPhotosVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "embassyPhotoCollectionCell", for: indexPath) as! EmbassyPhotoCollectionCell
        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! EmbassyPhotoCollectionCell
        let currentPhoto = photos[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        if useCustomOverlay {
            galleryPreview.overlayView = INSPhotosOverlayView(frame: CGRect.zero)
        }
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? EmbassyPhotoCollectionCell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
    }
}
