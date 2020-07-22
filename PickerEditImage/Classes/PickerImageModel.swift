//
//  PickerImageModel.swift
//  FBSnapshotTestCase
//
//  Created by Teeramet on 15/7/2563 BE.
//

import Foundation
import Photos
public class PickerImageModel{
    public var image : UIImage?
    public var phAsset : PHAsset?
    public var data : Data?
    public var fileExtension :String? = ""
    public var fileName :String? = ""
    var isSelect : Bool = false
    var createDate : Date?
    var isCreateView :Bool = false
    var rotate : CGFloat = 0
    var crop : CGRect = CGRect.zero
}
