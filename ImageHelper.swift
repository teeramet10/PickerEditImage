//
//  ImageExtension.swift
//  CropViewController
//
//  Created by Teeramet on 20/7/2563 BE.
//

import Foundation


public extension UIImage{
    private static var podsBundle: Bundle {
        let bundle = Bundle(for: PickerEdit)
        return Bundle(url: bundle.url(forResource: "PickerEditImage",
                                      withExtension: "bundle")!)!
    }

    private static func imageFor(name imageName: String) -> UIImage {
        return UIImage.init(named: imageName, in: podsBundle, compatibleWith: nil)!
    }

}
