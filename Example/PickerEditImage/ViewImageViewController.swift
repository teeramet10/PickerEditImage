//
//  ViewImageViewController.swift
//  PickerEditImage_Example
//
//  Created by Teeramet on 20/7/2563 BE.
//  Copyright © 2563 CocoaPods. All rights reserved.
//

import UIKit
import PickerEditImage
class ViewImageViewController: UIViewController {

    static let identifier = "ViewImageViewController"
    @IBOutlet weak var imagepageVIew: ImagePageView!
    
    var pickerModel : PickerImageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = pickerModel?.image else{return}
        imagepageVIew.setImage(image)
    }
    

    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
