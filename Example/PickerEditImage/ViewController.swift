//
//  ViewController.swift
//  PickerEditImage
//
//  Created by teeramet.kan@gmail.com on 07/15/2020.
//  Copyright (c) 2020 teeramet.kan@gmail.com. All rights reserved.
//

import PickerEditImage
import UIKit
class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pickerButton: UIButton!
    
    var list : [PickerImageModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.nib, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize.init(width: UIScreen.main.bounds.width/3.2, height: UIScreen.main.bounds.width/3)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = flowLayout
    }

    
    @IBAction func onPicker(_ sender: Any) {
        let vc =  PickerImageAlbumViewController.instantiateViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}


extension ViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else{return UICollectionViewCell()}
        cell.imageView.image = list[indexPath.row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ViewImageViewController.identifier) as? ViewImageViewController else{return}
        vc.pickerModel = list[indexPath.row]
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension ViewController : PickerImageAlbumViewControllerDelegate{
    
    func onSelect(_ selectedImage: [PickerImageModel]) {
        
        UIImage.init(data: <#T##Data#>)
        selectedImage.forEach{model in
            list.append(model)
        }
        collectionView.reloadData()
    }
}
