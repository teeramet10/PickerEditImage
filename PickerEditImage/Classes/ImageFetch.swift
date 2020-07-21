//
//  ImageFetch.swift
//  CropViewController
//
//  Created by Teeramet on 21/7/2563 BE.
//

import Foundation
import UIKit
class ImageFetch  :Operation{
     var pickerImageModel: PickerImageModel?
    
     var loadingCompleteHandler: ((PickerImageModel , UIImage) -> Void)?
     
     private let _pickerImageModel: PickerImageModel
     
    var image : UIImage?

     init(_ pickerImageModel: PickerImageModel) {
       _pickerImageModel = pickerImageModel
     }
     

    override func main() {
        if isCancelled { return }
        
        guard let assert = _pickerImageModel.phAsset else{return}
        let size =  CGSize.init(width: assert.pixelWidth, height: assert.pixelHeight)
        PhotoManager.getImageAssert(asset: assert, size: size, completionBlock: {image in
            if self.isCancelled { return }
            self.pickerImageModel = self._pickerImageModel
            self.image = image
            if let loadingCompleteHandler = self.loadingCompleteHandler {
                DispatchQueue.main.async {
                    loadingCompleteHandler(self._pickerImageModel, image)
                }
            }
        })
     }
}
