//
//  PickerEditImageViewController.swift
//  FBSnapshotTestCase
//
//  Created by Teeramet on 15/7/2563 BE.
//


import UIKit
import CropViewController
import Photos
public class PickerEditImageViewController: UIViewController ,UIScrollViewDelegate{
    
    static let identifier = "PickerEditImageViewController"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pageControlView: UIView!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var selectedImage : [PickerImageModel] = []
    var onEditing : ((PickerImageModel)->Void)?
    
    var onDeSelect : ((PickerImageModel,Int)->Void)?
    var onSelect : ((PickerImageModel,Int)->Void)?
    var onSend : (([PickerImageModel])->Void)?
    
    var timer : Timer?
    var currentIndex : Int = 0
    var images : [PickerImageModel] = []
    var isFirst : Bool = false
    
    let loadingQueue = OperationQueue()
    var loadingOperations: [IndexPath: ImageFetch] = [:]
    
    public static func instantiateViewController() -> PickerEditImageViewController {
        let podBundle = Bundle(for: PickerEditImageViewController.self)
        
        let bundleURL = podBundle.url(forResource: "PickerEditImage", withExtension: "bundle")
        let bundle = Bundle.init(url:bundleURL! )!
        
        let storyboard = UIStoryboard.init(name: "Storyboard", bundle: bundle)
        
        let vc = storyboard.instantiateViewController(withIdentifier: PickerEditImageViewController.identifier) as!  PickerEditImageViewController
        
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setToolbar()
        sendButton.title = "Send"
        guard images.count > currentIndex else{return}
        
        self.labelCount.text = "\(currentIndex+1)/\(images.count)"
        afterHideControl()
        
        
    }
    
    
    func setToolbar(){
        self.toolbar.isTranslucent = true
        self.toolbar.setBackgroundImage(UIImage(),
                                        forToolbarPosition: UIBarPosition.any,
                                        barMetrics: UIBarMetrics.default)
        self.toolbar.setShadowImage(UIImage(),
                                    forToolbarPosition: UIBarPosition.any)
    }
    
    func setupView(){
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.dataSource = self
        let podBundle = Bundle(for: PickerEditImageViewController.self)
        
        let bundleURL = podBundle.url(forResource: "PickerEditImage", withExtension: "bundle")
        let bundle = Bundle.init(url:bundleURL! )!
        
        let nib =  UINib(nibName: PageImageViewCollectionViewCell.identifier, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: PageImageViewCollectionViewCell.identifier)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        self.collectionView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showControl)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onTapDefault(sender:)))
        tap.numberOfTapsRequired = 2
        self.collectionView.addGestureRecognizer(tap)
    }
    
    public override func viewDidLayoutSubviews() {
        if !isFirst{
            isFirst = true
            self.scrollToPage(page: currentIndex, animated: false,position:.right)
            self.setViewSelectButton(currentIndex)
        }
        guard let flowLayout =  collectionView.collectionViewLayout as? UICollectionViewFlowLayout else{
            return
        }
        flowLayout.invalidateLayout()
    }
    
    
    func enableSend(){
        sendButton.isEnabled = true
        sendButton.tintColor = UIColor.white
    }
    
    func disableSend(){
        sendButton.isEnabled = false
        sendButton.tintColor = UIColor.gray
    }
    
    @IBAction func onSelect(_ sender: Any) {
        images[currentIndex].isSelect =  !images[currentIndex].isSelect
        setViewSelectButton(currentIndex)
        if  images[currentIndex].isSelect {
            onSelect?(images[currentIndex],currentIndex)
        }else{
            onDeSelect?(images[currentIndex],currentIndex)
        }
    }
    
    @IBAction func onCrop(_ sender: Any) {
        guard let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, section: 0)) as? PageImageViewCollectionViewCell else{
            return
        }
        
        guard let gallery = cell.imagePageView.gallery else{return}
        //        guard let image = gallery.image else{return}
        guard let assert = gallery.phAsset else{return}
        
        func toCrop(_ image :UIImage){
            let cropViewController = CropViewController(croppingStyle: .default, image: image)
            cropViewController.delegate = self
            if gallery.crop != .zero{
                cropViewController.imageCropFrame = gallery.crop
            }
            
            if gallery.rotate != 0 {
                let angle = Int(gallery.rotate)
                cropViewController.angle = angle
            }
            self.present(cropViewController, animated: true, completion: nil)
        }
        
        
        PhotoManager.getImageAssert(asset: assert, size:PHImageManagerMaximumSize, completionBlock: {image in
            toCrop(image)
        })
        
        
        
    }
    
    func setViewSelectButton(_ index :Int ){
        if  images[currentIndex].isSelect {
            btnSelect.setImage(ImageHelper.imageFor(named: "ic_available"), for: .normal)
        }else{
            btnSelect.setImage(ImageHelper.imageFor(named: "ic_checkbox"), for: .normal)
        }
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flowLayout =  collectionView.collectionViewLayout as? UICollectionViewFlowLayout else{
            return
        }
        flowLayout.invalidateLayout()
        
        let offset = collectionView.contentOffset
        let newOffset = CGPoint(x: CGFloat(currentIndex) * size.width, y: offset.y)
        coordinator.animate(alongsideTransition: {(context) in
            self.collectionView.setContentOffset(newOffset, animated: false)
            
        }, completion: nil)
        
    }
    
    
    @IBAction func onDissmiss(_ sender: Any) {
        onSend?([])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onForward(_ sender: Any) {
        if currentIndex>0{
            currentIndex -= 1
            labelCount.text = "\(currentIndex+1)/\(images.count)"
            scrollToPage(page: currentIndex, animated: true,position : .left)
        }
        showControl()
    }
    
    @IBAction func onNext(_ sender: Any) {
        if currentIndex < images.count-1{
            currentIndex += 1
            labelCount.text = "\(currentIndex+1)/\(images.count)"
            scrollToPage(page: currentIndex, animated: true,position : .right)
        }
        showControl()
    }
    @IBAction func onSendImage(_ sender: Any) {
        var selectedImage : [PickerImageModel] = []
        images.forEach{data in
            let isSelect = data.isSelect
            if isSelect{
                selectedImage.append(data)
            }
        }
        dismiss(animated: true, completion: {
            self.onSend?(selectedImage)
        })
    }
    
    func scrollToPage(page: Int, animated: Bool , position : UICollectionView.ScrollPosition) {
        collectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: position, animated: animated)
    }
    
    @objc func showControl(){
        UIView.animate(withDuration: 0.5, animations: {[unowned self]in
            self.pageControlView.alpha = 1
            self.closeButton.alpha = 1
        })
        
        afterHideControl()
    }
    
    func cancelTimer(){
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func afterHideControl(){
        cancelTimer()
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(hideControl), userInfo: nil, repeats: false)
    }
    
    @objc func hideControl(){
        UIView.animate(withDuration: 0.5, animations: {[unowned self]in
            self.pageControlView.alpha = 0
            self.closeButton.alpha = 0
        })
    }
    
    @objc func onTapDefault(sender : UITapGestureRecognizer){
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? PageImageViewCollectionViewCell else{
            return
        }
        
        
        let imagepage = cell.imagePageView.scrollView
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                if imagepage?.zoomScale == 1{
                    imagepage?.zoomScale = 2.0
                }else{
                    imagepage?.zoomScale = 1.0
                }
            })
        }
    }
}

extension PickerEditImageViewController: CropViewControllerDelegate{
    public func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        if angle != 0{
            images[currentIndex].rotate =  CGFloat(angle)
        }
        images[currentIndex].crop = cropRect
        
        
        if let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, section: 0)) as? PageImageViewCollectionViewCell{
            cell.imagePageView.imageView.image = image
        }
        
        onEditing?(images[currentIndex])
        
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
    
    private func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
    }
}

extension PickerEditImageViewController{
    func loadData(at index: Int) -> ImageFetch? {
        if (0..<images.count).contains(index) {
            return ImageFetch(images[index])
        }
        return .none
    }
}

extension PickerEditImageViewController : UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return   UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageImageViewCollectionViewCell.identifier, for: indexPath) as? PageImageViewCollectionViewCell else{return UICollectionViewCell()}
        cell.setCell(.none, image: .none, index: indexPath.row)
        return cell
        
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if currentIndex == indexPath.row {
            guard let visible = collectionView.visibleCells.first else { return }
            guard let index = collectionView.indexPath(for: visible)?.row else { return }
            currentIndex = index
            labelCount.text = "\(currentIndex+1)/\(images.count)"
            setViewSelectButton(currentIndex)
            
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PageImageViewCollectionViewCell else { return }
        let updateCellClosure: (PickerImageModel? , UIImage) -> Void = { [weak self] (pickerImageModel , image) in
            guard let self = self else {
                return
            }
            
            guard let model = pickerImageModel else{return}
            cell.setCell(model,image: image, index: indexPath.row)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        if let dataLoader = loadingOperations[indexPath] {
            if let model = dataLoader.pickerImageModel  , let image = dataLoader.image{
                cell.setCell(model,image: image, index: indexPath.row)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        }else{
            guard let dataLoader = loadImageOperation(at: indexPath.row) else{return}
            dataLoader.loadingCompleteHandler = updateCellClosure
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
    }
    
    func loadImageOperation(at index: Int) -> ImageFetch? {
        let  list = images
        if (0..<images.count).contains(index) {
            return ImageFetch(list[index])
        }
        return .none
    }
}

extension PickerEditImageViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView,prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] {
                continue
            }
            if let dataLoader = loadImageOperation(at: indexPath.item) {
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}
