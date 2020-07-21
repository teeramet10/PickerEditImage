//
//  ImageExtension.swift
//  CropViewController
//
//  Created by Teeramet on 20/7/2563 BE.
//

import Foundation


public class ImageHelper{
    private static var podsBundle: Bundle {
        let bundle = Bundle(for: ImageHelper.self)
        return Bundle(url: bundle.url(forResource: "PickerEditImage",
                                      withExtension: "bundle")!)!
    }

    static func imageFor(named imageName: String) -> UIImage {
        return UIImage.init(named: imageName, in: podsBundle, compatibleWith: nil)!
    }

}
