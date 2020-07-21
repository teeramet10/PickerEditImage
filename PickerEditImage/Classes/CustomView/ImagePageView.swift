
//
//  ImagePageView.swift
//  OneChat
//
//  Created by Teeramet on 7/11/2561 BE.
//  Copyright © 2561 Link-Swift. All rights reserved.
//

import UIKit
import Photos

public protocol ImagePageViewDelegate{
    func onDismiss()
}
public class ImagePageView: BaseCustomView {

    static let identifier = "ImagePageView"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    
    var gallery :PickerImageModel?
    var isSelectState = false
    var index : Int = 0
    var url : String? = ""
    var imageScale : CGFloat = 1.0
    var isLoading = false
    var delegate : ImagePageViewDelegate?
    
    func initComponent(){
        self.setSelectButton()
        self.setupScrollView()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChangeNotification), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    public func setImage(_ image : UIImage){
        imageView.image = image
    }
    
    func setDefaultImage(){
        imageView.image = nil
    }
    
    func setSelectButton(){
        if isSelectState{
            selectButton.isHidden = false
        }else{
            selectButton.isHidden = true
        }
    }

    func setupScrollView(){
        scrollView.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin,.flexibleLeftMargin]
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = container.bounds.size
       
    }
    
    @objc func deviceOrientationDidChangeNotification(_ notification: Any) {
          scrollView.zoomScale = 1.0
    }
    
    
    func refreshImage(model : PickerImageModel){
        self.imageView.image = imageView.image?.fixOrientation().rotate(model.rotate)
    }

    func rotateImage(){
        self.imageView.image =  self.imageView.image?.rotate(-90)
    }
    
    func showImageFromAsset(){
        self.setSelectButton()
        guard  let imageModel = gallery else {  return }
        guard let asset = imageModel.phAsset else { return }
        guard !isLoading else{return}
        isLoading = true
        guard self.imageView.image == nil else{return}
        let pxW = asset.pixelWidth
        let pxH = asset.pixelHeight
    
        DispatchQueue.global().sync {
            PhotoManager.getImageAssert(asset: asset, size: CGSize.init(width: pxW, height: pxH) , completionBlock: {[weak self] image in
                guard let strongSelf = self else{return }
                strongSelf.isLoading = false
                DispatchQueue.main.async {
                    let newImage =  image.rotate(imageModel.rotate)?.cropToRect(imageModel.crop)
                    if strongSelf.imageView.image == nil{
                        strongSelf.imageView.image = newImage
                    }
                }
            })
        }
            
//            let imgManager = PHImageManager.default()
//
//            let option = PHImageRequestOptions.init()
//            option.resizeMode = .exact
//            option.deliveryMode = .opportunistic
//            option.isNetworkAccessAllowed = true
//            option.isSynchronous = true
//            let size = UIScreen.main.bounds.size
//            imgManager.requestImage(for: asset, targetSize:size, contentMode: PHImageContentMode.default, options: option , resultHandler: {[weak self] (image,info) in
//                guard let strongSelf = self else{
//                    return
//                }
//                DispatchQueue.main.async {
//                    if strongSelf.imageView.image == nil{
//                        strongSelf.imageView.image = image?.rotate(imageModel.rotate)?.cropToRect(imageModel.crop)
//                        strongSelf.gallery?.image = image
//                    }
//                }
//            })
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let isSelect = gallery?.isSelect ?? false
        if  isSelect{
            selectButton.setImage(ImageHelper.imageFor(named: "ic_checkbox"), for: .normal)
            gallery?.isSelect = false
        }else{
             selectButton.setImage(ImageHelper.imageFor(named: "ic_available"), for: .normal)
            gallery?.isSelect = true
        }
    }
}

extension ImagePageView : UIGestureRecognizerDelegate{
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
extension ImagePageView : UIScrollViewDelegate{
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return  self.container
    }
    
    private func centerImage() {
        let imageViewSize = container.frame.size
        let scrollViewSize = scrollView.frame.size
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 1
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 1
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()

    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.zoomScale == 1.0 else{return}
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 300 {
            delegate?.onDismiss()
        }else  if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < -300{
            delegate?.onDismiss()
        }
    }
}
