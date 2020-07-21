//
//  ImageCollectionViewCell.swift
//  OneChat
//
//  Created by Teeramet on 15/10/2561 BE.
//  Copyright © 2561 Link-Swift. All rights reserved.
//

import UIKit
import Photos

public protocol ImageCollectionViewCellDelegate{
    func onSelectImage(_ cell:ImageCollectionViewCell,index : Int)
}
public class ImageCollectionViewCell: UICollectionViewCell {
    
    static var idenifier = "ImageCollectionViewCell"
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgSelect: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var imgVideo: UIImageView!
    
    var index : Int = 0
    var delegate : ImageCollectionViewCellDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        imgVideo.image = ImageHelper.imageFor(named: "ic_video").withRenderingMode(.alwaysTemplate)
        imgVideo.tintColor = UIColor.white
    }
    
    
    
    func setUpViewCell(image : PickerImageModel?,index: Int){
        
        guard  let imageModel = image else {
            return
        }
        
        guard let asset = imageModel.phAsset else {
            return
        }
        
        self.index = index
        self.imgView.image = ImageHelper.imageFor(named: "ic_loading")
        
        DispatchQueue.global().sync {
            
            PhotoManager.getImageAssert(asset: asset, size: PHImageManagerMaximumSize, completionBlock: { image in
                DispatchQueue.main.async {
                    self.imgView.image = image
                }
            })
        }
    
        if imageModel.isSelect{
            imgSelect.setImage(ImageHelper.imageFor(named: "ic_available"), for: .normal)
        }else{
            imgSelect.setImage(ImageHelper.imageFor(named: "ic_checkbox"), for: .normal)
        }
        
    }
    
    func setCell(_ asset : PHAsset){
        
    }
    
    open var duration: TimeInterval? {
        didSet {
            guard let duration = self.duration else { return }
            self.timeLabel.text = timeFormatted(timeInterval: duration)
        }
    }
    
    @objc open func timeFormatted(timeInterval: TimeInterval) -> String {
        let seconds: Int = lround(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }
    
    
    
    @IBAction func onSelectImage(_ sender: Any) {
        delegate?.onSelectImage(self,index: index)
    }
}


