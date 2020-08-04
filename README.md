# PickerEditImage

[![CI Status](https://img.shields.io/travis/teeramet.kan@gmail.com/PickerEditImage.svg?style=flat)](https://travis-ci.org/teeramet.kan@gmail.com/PickerEditImage)
[![Version](https://img.shields.io/cocoapods/v/PickerEditImage.svg?style=flat)](https://cocoapods.org/pods/PickerEditImage)
[![License](https://img.shields.io/cocoapods/l/PickerEditImage.svg?style=flat)](https://cocoapods.org/pods/PickerEditImage)
[![Platform](https://img.shields.io/cocoapods/p/PickerEditImage.svg?style=flat)](https://cocoapods.org/pods/PickerEditImage)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 10.0+

## Installation

PickerEditImage is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PickerEditImage'
```

## ScreenShot

<table align = "center">
 <tr> Select image and album  </tr>
 <tr>
<p align = "center">

<img src ="https://github.com/teeramet10/PickerEditImage/blob/master/screenshot/screen1.png" width="280">
<img src ="https://github.com/teeramet10/PickerEditImage/blob/master/screenshot/screen2.png" width="280">
</p>
 </tr>
  <tr>  Show full size and crop image  </tr>
 <tr>
<p  align = "center">

<img src ="https://github.com/teeramet10/PickerEditImage/blob/master/screenshot/screen3.png" width="280">
<img src ="https://github.com/teeramet10/PickerEditImage/blob/master/screenshot/screen4.png" width="280">
</p>
 </tr>
 
 </table>


## Getting Started

Import 
```
import PickerEditImage

```

Initialization and presentation
```
 let vc =  PickerImageAlbumViewController.instantiateViewController()
 vc.delegate = self
 self.present(vc, animated: true, completion: nil)
```

Methods 
```
class ViewController : PickerImageAlbumViewControllerDelegate{
    
    //Mark - PickerImageAlbumViewControllerDelegate methods
    
    func onSelect(_ selectedImage: [PickerImageModel]) {
        let model = selectedImage[0]
        self.imageView.image = model.image
        
        self.imageView.image = UIImage.init(data:model.data)

        print(model.fileExtension)
        print(model.fileName)

    }
}

```

## Author

teeramet.kan@gmail.com

## License

PickerEditImage is available under the MIT license. See the LICENSE file for more info.
