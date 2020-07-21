//
//  SelectAlbumPopupView.swift
//  OneChat
//
//  Created by Teeramet on 20/8/2562 BE.
//  Copyright © 2562 Link-Swift. All rights reserved.
//

import Foundation
import UIKit
public class SelectAlbumPopupView: BaseCustomView,PopupViewProtocol {
    @IBOutlet open var bgView: UIView!
    @IBOutlet open var popupView: UIView!
    @IBOutlet var popupViewHeight: NSLayoutConstraint!
    @IBOutlet open var tableView: UITableView!
    @IBOutlet weak var imagePopup: UIImageView!
    
    @objc public var originalFrame = CGRect.zero
    @objc public var show = false
    
    deinit {
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    
    override func initView() {
        self.popupView.layer.cornerRadius = 5.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBgView))
        self.bgView.addGestureRecognizer(tapGesture)
        let podBundle = Bundle(for: SelectAlbumTableViewCell.self)
        
        let bundleURL = podBundle.url(forResource: "PickerEditImage", withExtension: "bundle")
        let bundle = Bundle.init(url:bundleURL! )!
        let nib = UINib.init(nibName: SelectAlbumTableViewCell.identifier, bundle: bundle)

        self.tableView.register(nib, forCellReuseIdentifier: SelectAlbumTableViewCell.identifier)
    }
    
    @objc func tapBgView() {
        self.show(false)
    }
}
