//
//  PickerImageAlbumViewController.swift
//  CropViewController
//
//  Created by Teeramet on 15/7/2563 BE.
//


import UIKit
import Photos
public protocol PickerImageAlbumViewControllerDelegate {
    func onSelect(_ selectedImage :[PickerImageModel])
}


public class PickerImageAlbumViewController: UIViewController {
    
    static var identifier = "PickerImageAlbumViewController"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectImage :[PickerImageModel] = []
    var editingImage :[PickerImageModel] = []
    public var delegate : PickerImageAlbumViewControllerDelegate?
    
    @IBOutlet weak var popupView: SelectAlbumPopupView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageArrowPopup: UIImageView!
    
    let photoManager = PhotoManager.init()
    
    var collection: [AssetsCollection] = []
    
    var imageCollection: [PickerImageModel] = []
    
    var cacheImageCollection: [Int:[PickerImageModel]] = [:]
    
    var selectAlbum :AssetsCollection? = nil
    
    var complete :(([PickerImageModel])->Void)?
    
    var isCancel = false
    
    public static func instantiateViewController() -> PickerImageAlbumViewController {
        let podBundle = Bundle(for: PickerImageAlbumViewController.self)
        
        let bundleURL = podBundle.url(forResource: "PickerEditImage", withExtension: "bundle")
        let bundle = Bundle.init(url:bundleURL! )!
        
        let storyboard = UIStoryboard.init(name: "Storyboard", bundle: bundle)
        
        let vc = storyboard.instantiateViewController(withIdentifier: PickerImageAlbumViewController.identifier) as!  PickerImageAlbumViewController
        
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        photoManager.delegate = self
        if let presentVC = presentationController{
            presentVC.delegate = self
        }
        
        if selectAlbum != nil{
            cacheImageCollection[selectIndex()] = imageCollection
        }
        fetchCollection()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    
    @IBAction func onCancel(_ sender: Any) {
        cancel()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        if(selectImage.count > 0){
            sendImage()
        }
    }
    
    func clearData(){
        cacheImageCollection = [:]
        selectImage = []
        editingImage = []
        selectAlbum = nil
        imageCollection.forEach{
            $0.rotate = 0
            $0.crop = CGRect.zero
            $0.isSelect = false
        }
    }
    
    func fetchCollection(){
        photoManager.fetchCollection(viewController: self)
    }
    
    private func selectIndex() -> Int {
        guard let selected = self.selectAlbum, let result = self.collection.firstIndex(where: { $0 == selected }) else { return 0 }
        return result
    }
    
    func setUpView(){
        let podBundle = Bundle(for: ImageCollectionViewCell.self)
        
        let bundleURL = podBundle.url(forResource: "PickerEditImage", withExtension: "bundle")
        let bundle = Bundle.init(url:bundleURL! )!
        
        let nib =  UINib.init(nibName: ImageCollectionViewCell.idenifier, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: ImageCollectionViewCell.idenifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initTableView()
        
        imageArrowPopup.transform = CGAffineTransform.init(scaleX: 1, y: -1)
        
        viewTitle.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapShowAlbum)))
    }
    
    func cancel(){
        complete?(selectImage)
        clearData()
    }
    
    func sendImage(){
        var pickerList : [PickerImageModel] = []
        for index in 0...selectImage.count-1 {
            getOriginalSize(selectImage[index]){[weak self]picker in
                guard let strongSelf = self else{return}
                if index == strongSelf.selectImage.count-1{
                    pickerList.append(picker)
                    strongSelf.delegate?.onSelect(pickerList)
                    strongSelf.dismiss(animated: true, completion: nil)
                }else{
                    pickerList.append(picker)
                }
            }
        }
        
    }
    
    private func getOriginalSize(_ model :PickerImageModel,_ complete:@escaping ((PickerImageModel)-> Void)){
        guard let asset = model.phAsset else{return}
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        
        let size = PHImageManagerMaximumSize
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.default, options: option, resultHandler:  {(image,info) in
            guard let image = image else{return}
            self.sortImage(model,image,complete)
        })
    }
    
    private func sortImage(_ model :PickerImageModel,_ image :UIImage,_ complete:@escaping ((PickerImageModel)-> Void)){
        guard let asset = model.phAsset else{return}
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = true
        
        func requestImage(_ info :[AnyHashable : Any]?){
            guard let name = info?["PHImageFileUTIKey"] as? String else{return}
            guard let indexExtension = name.index(of: ".") else{return}
            var fileExtension = String(name.suffix(from: indexExtension))
            fileExtension = fileExtension == "heic" ? "jpeg" : fileExtension
            guard let img = image.rotate(model.rotate)?.cropToRect(model.crop) else { return }
            guard let data = img.jpegData(compressionQuality: 1.0) else{return}
            let newModel = PickerImageModel()
            newModel.phAsset = asset
            newModel.fileName = name
            newModel.image = img
            newModel.data = data
            newModel.fileExtension = fileExtension
            complete(newModel)
            
        }
        
        if #available(iOS 13, *) {
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option, resultHandler: {(data,dataUTI,orientation,info) in
                requestImage(info)
            })
        } else {
            PHImageManager.default().requestImageData(for: asset, options: option, resultHandler: {(data,dataUTI,orientation,info) in
                requestImage(info)
            })
        }
        
    }
    
    @objc func tapShowAlbum(){
        guard collection.count > 0 else { return }
        self.popupView.show(self.popupView.isHidden)
    }
    
    func initTableView(){
        self.popupView.tableView.delegate = self
        self.popupView.tableView.dataSource = self
        
    }
    
    private func reloadTableView() {
        let count = min(5, self.collection.count)
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            var frame = self.popupView.popupView.frame
            frame.size.height = CGFloat(count * 75)
            self.popupView.popupViewHeight.constant = CGFloat(count * 75)
            UIView.animate(withDuration: self.popupView.show ? 0.1:0) {
                self.popupView.popupView.frame = frame
                self.popupView.setNeedsLayout()
            }
            self.popupView.tableView.reloadData()
            self.popupView.setupPopupFrame()
        }
        
    }
    
    private func updateTitle() {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.titleLabel.text = self.selectAlbum?.title
            self.subtitleLabel.text = "Tab here to change"
        }
    }
    
}

extension PickerImageAlbumViewController: PhotoManagerDelegate {
    func loadNewCompleteCollection(_ collection: [AssetsCollection]) {
        self.collection = collection
        if let imageCollection = collection.first {
            self.focusedRefresh(collection: imageCollection)
        }
        self.reloadTableView()
    }
    
    func loadCompleteCollection(_ collection: [AssetsCollection]) {
        self.collection = collection
        if let imageCollection = collection.first {
            self.focused(collection: imageCollection)
        }
        self.reloadTableView()
    }
    
}

extension PickerImageAlbumViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCollection.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.idenifier, for: indexPath) as? ImageCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.imgView.image = nil
        cell.index = indexPath.row
        cell.delegate = self
        let model = imageCollection[indexPath.row]
        guard let phasset = model.phAsset else{
            return UICollectionViewCell()
        }
        
        let smallSize = CGSize.init(width: 160, height: 160)
        let scale = min(UIScreen.main.scale,2)
        let targetSize = CGSize(width: smallSize.width*scale, height: smallSize.height*scale)
        let size = model.crop != .zero ? PHImageManagerMaximumSize : targetSize
        let contentMode  : PHImageContentMode = model.crop != .zero ? .aspectFit : .aspectFill
        PhotoManager.getImageAssert(asset: phasset, size: size,contentMode: contentMode, completionBlock: {(images) in
            let data = self.imageCollection[indexPath.row]
            cell.imgView.image = images.fixOrientation().rotate(data.rotate)?.cropToRect(data.crop)
            //            self.imageCollection[indexPath.row].image = images
        })
        guard let asset = imageCollection[indexPath.row].phAsset else { return cell }
        
        if asset.mediaType == .video{
            cell.timeView.isHidden = false
            cell.duration = asset.duration
        }else{
            cell.timeView.isHidden = true
        }
        
        if  self.selectImage.firstIndex(where: {
                                            $0.phAsset?.localIdentifier == asset.localIdentifier}) != nil
        {
            cell.imgSelect.setImage(ImageHelper.imageFor(named: "ic_available"), for: .normal)
        }else{
            cell.imgSelect.setImage(ImageHelper.imageFor(named: "ic_checkbox"), for: .normal)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size :CGFloat = 3
        if UIDevice.current.userInterfaceIdiom == .pad{
            size = 5
        }
        if UIDevice.current.orientation == .landscapeLeft ||  UIDevice.current.orientation == .landscapeRight{
            size = 5
        }
        let width =  self.collectionView.frame.width / size
        return CGSize.init(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let editVC = PickerEditImageViewController.instantiateViewController()
        
        editVC.selectedImage = selectImage
        editVC.images = imageCollection
        editVC.currentIndex =  indexPath.row
        editVC.modalPresentationStyle = .overFullScreen
        
        func checkSend(){
            if selectImage.count > 0 {
                editVC.enableSend()
            }else{
                editVC.disableSend()
            }
        }
        
        editVC.onSend = {[weak self] data in
            guard let strongSelf = self else{return}
            strongSelf.collectionView.reloadData()
            if data.count > 0 {
                strongSelf.dismiss(animated: true, completion: {
                    strongSelf.sendImage()
                })
            }
        }
        editVC.onEditing = {[weak self] (data) in
            guard let strongSelf = self else{return}
            let list = strongSelf.editingImage.filter{$0.phAsset?.localIdentifier == data.phAsset?.localIdentifier}
            
            if list.count > 0{
                list.first?.rotate = data.rotate
                list.first?.crop = data.crop
            }else{
                strongSelf.editingImage.append(data)
            }
        }
        
        editVC.onSelect = {[weak self] (data,index) in
            
            guard let strongSelf = self else{return}
            strongSelf.imageCollection[index].isSelect = true
            strongSelf.selectImage.append(strongSelf.imageCollection[index])
            
            checkSend()
        }
        
        editVC.onDeSelect = {[weak self] (data,index) in
            
            guard let strongSelf = self else{return}
            strongSelf.imageCollection[index].isSelect = false
            if let index = strongSelf.selectImage.firstIndex(where: {
                guard let localIdentifier = $0.phAsset?.localIdentifier else{return false}
                let current = data.phAsset?.localIdentifier
                return localIdentifier == current
                
            }){
                strongSelf.selectImage.remove(at: index)
            }
            
            checkSend()
            
        }
        self.present(editVC, animated: true, completion: {})
        checkSend()
        
    }
    
    private func reloadCollection(){
        
        DispatchQueue.main.async {[weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension PickerImageAlbumViewController : UITableViewDataSource,UITableViewDelegate{
    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collection.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:SelectAlbumTableViewCell.identifier, for: indexPath) as! SelectAlbumTableViewCell
        let collection = self.collection[indexPath.row]
        cell.nameLabel.text = collection.title
        
        cell.countLabel.text = "\(collection.fetchResult?.count ?? 0)"
        if let phAsset = collection.getAsset(at: 0) {
            let scale = UIScreen.main.scale
            let size = CGSize(width: 80*scale, height: 80*scale)
            self.photoManager.imageAsset(asset: phAsset, size: size, completionBlock: { [weak cell] (image,complete) in
                DispatchQueue.main.async {
                    cell?.imageAlbum.image = image
                }
            })
        }
        cell.accessoryType = selectIndex() == indexPath.row ? .checkmark : .none
        cell.selectionStyle = .none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        focused(collection: collection[indexPath.row])
    }
    
    private func focusedRefresh(collection: AssetsCollection){
        func resetRequest() {
            cancelAllImageAssets()
        }
        resetRequest()
        self.selectAlbum = collection
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.collection[self.selectIndex()].recentPosition = self.collectionView.contentOffset
        }
        
        guard let fetchResult = collection.fetchResult else{return}
        
        var imageList :[PickerImageModel] = []
        for index in 0...fetchResult.count-1{
            let model = PickerImageModel()
            let list = self.editingImage.filter{$0.phAsset?.localIdentifier == fetchResult[index].localIdentifier}
            if list.count > 0{
                model.rotate = list.first?.rotate ?? 0
                model.crop = list.first?.crop ?? CGRect.zero
            }
            model.phAsset =  fetchResult[index]
            
            let selectlist = self.selectImage.filter{$0.phAsset?.localIdentifier == fetchResult[index].localIdentifier}
            if selectlist.count > 0{
                model.isSelect = true
            }
            imageList.append(model)
        }
        imageCollection = imageList
        cacheImageCollection[selectIndex()] = imageCollection
        
        
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.popupView.tableView.reloadData()
        }
        
        self.popupView.show(false)
        self.updateTitle()
        self.reloadCollection()
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.collectionView.contentOffset = collection.recentPosition
        }
    }
    
    private func focused(collection: AssetsCollection) {
        func resetRequest() {
            cancelAllImageAssets()
        }
        resetRequest()
        self.selectAlbum = collection
        self.collection[selectIndex()].recentPosition = self.collectionView.contentOffset
       
        guard let fetchResult = collection.fetchResult else{return}
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.collection[self.selectIndex()].recentPosition = self.collectionView.contentOffset
        }
        
        
        if  cacheImageCollection[selectIndex()] == nil{
            var imageList :[PickerImageModel] = []
            for index in 0...fetchResult.count-1{
                let model = PickerImageModel()
                let list = self.editingImage.filter{$0.phAsset?.localIdentifier == fetchResult.object(at: index).localIdentifier}
                if list.count > 0{
                    model.rotate = list.first?.rotate ?? 0
                    model.crop = list.first?.crop ?? CGRect.zero
                }
                model.phAsset =  fetchResult.object(at: index)
                
                 let selectlist = self.selectImage.filter{$0.phAsset?.localIdentifier == fetchResult.object(at: index).localIdentifier}
                if selectlist.count > 0{
                    model.isSelect = true
                }
                imageList.append(model)
            }
            imageCollection = imageList
            cacheImageCollection[selectIndex()] = imageList
        }else{
            imageCollection = cacheImageCollection[selectIndex()]  ?? []
            imageCollection.forEach{data in
                let list = self.editingImage.filter{$0.phAsset?.localIdentifier == data.phAsset?.localIdentifier}
                if list.count > 0{
                    data.rotate = list.first?.rotate ?? 0
                    data.crop = list.first?.crop ?? CGRect.zero
                }
                
            }
        }
        
        
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.popupView.tableView.reloadData()
        }
        
        self.popupView.show(false)
        self.updateTitle()
        self.reloadCollection()
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else{return}
            self.collectionView.contentOffset = collection.recentPosition
        }
        
    }
    
    private func cancelAllImageAssets() {

    }
    
    
}

extension PickerImageAlbumViewController:ImageCollectionViewCellDelegate{
    public func onSelectImage(_ cell: ImageCollectionViewCell, index: Int) {
        guard let asset =  imageCollection[index].phAsset else{return}
        
        if let selectindex = self.selectImage.firstIndex(where: {
            guard let localIdentifier = $0.phAsset?.localIdentifier else{return false}
            let current = asset.localIdentifier
            return localIdentifier == current
            
        }) {
            imageCollection[index].isSelect = false
            //deselect
            self.selectImage.remove(at: selectindex)
            cell.imgSelect.setImage(ImageHelper.imageFor(named: "ic_checkbox"), for: .normal)
        }else {
            imageCollection[index].isSelect = true
            self.selectImage.append(imageCollection[index])
            cell.imgSelect.setImage(ImageHelper.imageFor(named: "ic_available"), for: .normal)
            
        }
        
        
    }
}

extension PickerImageAlbumViewController : UIAdaptivePresentationControllerDelegate{
    private func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        cancel()
        return true
    }
}
