//
//  PageImageViewCollectionViewCell.swift
//  OneChat
//
//  Created by Teeramet on 20/6/2563 BE.
//  Copyright © 2563 Link-Swift. All rights reserved.
//

import UIKit

public class PageImageViewCollectionViewCell: UICollectionViewCell {

    static let identifier = "PageImageViewCollectionViewCell"
    static let nib = UINib(nibName: PageImageViewCollectionViewCell.identifier, bundle: nil)
    
    @IBOutlet weak var imagePageView: ImagePageView!
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func rotateImage(){
        imagePageView.rotateImage()
    }

    
    func setCell(_ data : PickerImageModel? , image : UIImage? , index : Int){
       
        guard let data = data else{
            setDefault()
            return
        }
        imagePageView.gallery = data
        imagePageView.index = index
        imagePageView.setSelectButton()
        imagePageView.imageView.image = image?.rotate(data.rotate)?.cropToRect(data.crop)
    }
    
    private func setDefault(){
        imagePageView.initComponent()
        imagePageView.setDefaultImage()
        imagePageView.isSelectState = true
    }

}
