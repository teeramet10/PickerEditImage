//
//  PhotoManager.swift
//  CropViewController
//
//  Created by Teeramet on 15/7/2563 BE.
//

import Foundation
import Photos

protocol PhotoManagerDelegate {
    func loadCompleteCollection(_ collection : [AssetsCollection])
}
class PhotoManager{
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    var delegate :PhotoManagerDelegate?
    
    func getOption() -> PHFetchOptions {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return options
    }
    
    
    func fetchCollection() {

        let options = getOption()
        
        @discardableResult
        func getSmartAlbum(subType: PHAssetCollectionSubtype, useCameraButton: Bool = false, result: inout [AssetsCollection]) -> AssetsCollection? {
            let fetchCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subType, options: nil)
            if let collection = fetchCollection.firstObject, !result.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                var assetsCollection = AssetsCollection(collection: collection)
                assetsCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                if assetsCollection.count > 0 {
                    result.append(assetsCollection)
                    return assetsCollection
                }
            }
            return nil
        }
        
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            var assetCollections = [AssetsCollection]()
            getSmartAlbum(subType: .smartAlbumUserLibrary, result: &assetCollections)
            //Selfies
            getSmartAlbum(subType: .smartAlbumSelfPortraits, result: &assetCollections)
            //Panoramas
            getSmartAlbum(subType: .smartAlbumPanoramas, result: &assetCollections)
            //Favorites
            getSmartAlbum(subType: .smartAlbumFavorites, result: &assetCollections)
            //CloudShared
            getSmartAlbum(subType: .albumCloudShared, result: &assetCollections)
            //Videos
            getSmartAlbum(subType: .smartAlbumVideos, result: &assetCollections)
            
            //Album
            let albumsResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            albumsResult.enumerateObjects({ (collection, index, stop) -> Void in
                guard let collection = collection as? PHAssetCollection else { return }
                var assetsCollection = AssetsCollection(collection: collection)
                assetsCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                
                if assetsCollection.count > 0, !assetCollections.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                    assetCollections.append(assetsCollection)
                }
            })
            
            DispatchQueue.main.async {
                self?.delegate?.loadCompleteCollection(assetCollections)
            }
            
        }
    }
    
    @discardableResult
    func imageAsset(asset: PHAsset, size: CGSize = CGSize(width: 160, height: 160), options: PHImageRequestOptions? = nil, completionBlock:@escaping (UIImage,Bool)-> Void ) -> PHImageRequestID {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.isSynchronous = false
            options?.resizeMode = .exact
            options?.deliveryMode = .opportunistic
            options?.isNetworkAccessAllowed = true
        }
//        let scale = min(UIScreen.main.scale,2)
//        let targetSize = CGSize(width: size.width*scale, height: size.height*scale)
        let size = UIScreen.main.bounds.size
        let requestID = self.imageManager.requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { image, info in
            let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
            if let image = image {
                completionBlock(image,complete)
            }
        }
        return requestID
    }
    
    func fetchResult(collection: AssetsCollection?) -> PHFetchResult<PHAsset>? {
        guard let phAssetCollection = collection?.phAssetCollection else { return nil }
        let options = getOption()
        return PHAsset.fetchAssets(in: phAssetCollection, options: options)
    }
    
    
    static func getImageAssert(asset: PHAsset, size: CGSize, options: PHImageRequestOptions? = nil ,contentMode : PHImageContentMode = .default, completionBlock:@escaping (UIImage)-> Void )  {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.isSynchronous = true
            options?.resizeMode = .exact
            options?.deliveryMode = .highQualityFormat
            options?.isNetworkAccessAllowed = true
        }        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: contentMode, options: options) { image, info in
            if let image = image {
                completionBlock(image)
            }
        }
    }
}

public struct AssetsCollection {
    var phAssetCollection: PHAssetCollection? = nil
    var fetchResult: PHFetchResult<PHAsset>? = nil
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


extension UIImage {
    func upOrientationImage() -> UIImage? {
        switch imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
}

