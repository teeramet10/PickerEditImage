//
//  SelectAlbumTableViewCell.swift
//  OneChat
//
//  Created by Teeramet on 31/5/2562 BE.
//  Copyright © 2562 Link-Swift. All rights reserved.
//

import UIKit

public class SelectAlbumTableViewCell: UITableViewCell {

    static let identifier = "SelectAlbumTableViewCell"
    
    @IBOutlet weak var imageAlbum: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var nameCenter: NSLayoutConstraint!
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        imageAlbum.layer.cornerRadius = 15
    }

    
    func configCell(_ albums : AlbumViewModel){
        
//        ImageLoader.loadImage(imageAlbum, url: albums.information.first?.link)
        
        nameLabel.text = albums.albumName
        
//        countLabel.text = aImageInAlbumViewModel.swiftlbums.information.count.toString()
        
        countLabel.isHidden = false
    }
    
    func configCell(){
        nameLabel.text = "Create album"
        nameCenter.constant = 0
        imageView?.image = UIImage.init(named: "ic_add")
        countLabel.isHidden = true
        
    }
  
    
}
