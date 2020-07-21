//
//  AlbumViewModel.swift
//  OneChat
//
//  Created by Teeramet on 21/5/2562 BE.
//  Copyright © 2562 Link-Swift. All rights reserved.
//

import Foundation
public class AlbumViewModel{
    
    var id :String? = ""
    var albumName :String? = ""
    var createBy : String? = ""
    var createDate :String? = ""
    var information :[ImageInAlbumViewModel] = []
    var picTitle :String? = ""
    var tokenroom:String? = ""
    var state :StateAlbumViewModel?
    
}

class StateAlbumViewModel{
    var actionDate :String? = ""
    var by  :String? = ""
    var status :String? = ""
    
}
