//
//  EmbassyPhotoCollectionCell.swift
//  EGVApp
//
//  Created by Fabricio on 27/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import INSPhotoGallery

class EmbassyPhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        photo.loadThumbnailImageWithCompletionHandler { [weak photo] (image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.thumbnailImage = image
                }
                self.imageView.image = image
            }
        }
    }
}
