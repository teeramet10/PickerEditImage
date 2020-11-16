//
//  PhotoManager.swift
//  CropViewController
//
//  Created by Teeramet on 15/7/2563 BE.
//

import Foundation
import Photos
import PhotosUI
import UIKit
import ImageIO

protocol PhotoManagerDelegate {
    func loadCompleteCollection(_ collection : [AssetsCollection])
}
class PhotoManager: NSObject{

    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    var delegate :PhotoManagerDelegate?
    
    var collection : [AssetsCollection] = []
    
    func getOption() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return options
    }
    
    func register(){
        PHPhotoLibrary.shared().register(self)
    }
    
    func checkPermission( completionHandler :@escaping  ((PHAuthorizationStatus)->Void)){
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                completionHandler(status)
            }
        } else {
            
        }
        
    }
    
    @available(iOS 14, *)
    func openLimitPhoto(viewController : UIViewController){
        var config = PHPickerConfiguration()
        config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 0 // default
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        DispatchQueue.main.async {[weak self ]in
            viewController.present(picker, animated: true)
        }
       
    }
    
    func refresh(){
        fetchCollection()
    }
    
    func fetchCollection(viewController : UIViewController){
        if #available(iOS 14, *) {
            checkPermission(completionHandler: {[weak self ]status in
                self?.fetchCollection()
            })
        } else {
            fetchCollection()
        }
    }
    
    private func fetchCollection() {
        
        let options = getOption()
        
        @discardableResult
        func getSmartAlbum(subType: PHAssetCollectionSubtype, useCameraButton: Bool = false, result: inout [AssetsCollection]) -> AssetsCollection? {
            
            let fetchCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subType, options: nil)
            guard let collection = fetchCollection.firstObject, !result.contains(where: { $0.localIdentifier == collection.localIdentifier }) else{
                return nil
            }
            var assetsCollection = AssetsCollection(collection: collection)
            let fetchResult = PHAsset.fetchAssets(in: collection, options: options)
            assetsCollection.fetchResult = fetchResult
            assetsCollection.fetchList = fetchResult.objects(at: IndexSet(integersIn:  0..<fetchResult.count))
            if assetsCollection.count > 0 {
                result.append(assetsCollection)
                return assetsCollection
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
            
            
            DispatchQueue.main.async {
                self?.collection = assetCollections
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
extension PhotoManager : PHPhotoLibraryChangeObserver{
   
    func photoLibraryDidChange(_ changeInstance: PHChange) {
      
        guard #available(iOS 14, *) else{return }
        self.checkPermission(completionHandler: {[weak self]status in
            guard let `self` = self else{return}
            guard status == .limited else{return}
            self.fetchCollection()
        })
       
    }
}

extension PhotoManager : PHPickerViewControllerDelegate{
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        let lsit = fetchResult.objects(at: IndexSet.init(integersIn: 0..<fetchResult.count))
        self.fetchCollection()
    }
}
