//
//  AssetCollection.swift
//  CropViewController
//
//  Created by Yumi JIn on 16/11/2563 BE.
//

import Foundation
import UIKit 
import Photos
public struct AssetsCollection {
    var phAssetCollection: PHAssetCollection? = nil
    var fetchResult: PHFetchResult<PHAsset>?
    var imageResult: [PickerImageModel] = []
    var recentPosition: CGPoint = CGPoint.zero
    var title: String
    var localIdentifier: String
    
    public var sections: [(title: String, assets: [PHAsset])]? = nil
    
    var count: Int {
        get {
            guard let count = self.fetchResult?.count, count > 0 else { return   0 }
            return count
        }
    }
    
    init(collection: PHAssetCollection) {
        self.phAssetCollection = collection
        self.title = collection.localizedTitle ?? ""
        self.localIdentifier = collection.localIdentifier
    }
    
    func getAsset(at index: Int) -> PHAsset? {
        guard let result = self.fetchResult, index < result.count else { return nil }
        return result.object(at: index)
    }
    
    
    
    static func ==(lhs: AssetsCollection, rhs: AssetsCollection) -> Bool {
        return lhs.localIdentifier == rhs.localIdentifier
    }
}
