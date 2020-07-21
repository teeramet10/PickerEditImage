//
//  BaseCustomView.swift
//  CropViewController
//
//  Created by Teeramet on 15/7/2563 BE.
//

import Foundation
@IBDesignable
public class BaseCustomView: UIView {

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
        self.initView()
    }
    
    
    // Performs the initial setup.
    fileprivate func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
       
        addSubview(view)
    }
    
    // Loads a XIB file into a view and returns this view.
    fileprivate func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        return view
    }
    
    func initView(){
        
    }

}
