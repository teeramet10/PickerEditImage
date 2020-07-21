//
//  ImageCollectionViewCell.swift
//  PickerEditImage_Example
//
//  Created by Teeramet on 20/7/2563 BE.
//  Copyright © 2563 CocoaPods. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = "ImageCollectionViewCell"
    static let nib = UINib.init(nibName: ImageCollectionViewCell.identifier, bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
