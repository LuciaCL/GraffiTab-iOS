//
//  ColorSprayCanCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 19/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

protocol ColorSprayCanCellDelegate: class {
    
    func didChooseColor(color: UIColor)
}

class ColorSprayCanCell: UITableViewCell {
    
    weak var delegate: ColorSprayCanCellDelegate?
    var colorBtns: [ColorSprayCan]?
    var colors: [UIColor]? {
        didSet {
            self.createColors()
        }
    }
    
    class func reusableIdentifier() -> String {
        return "ColorSprayCanCell"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        createColors()
    }
    
    func onClickColor(recognizer: UIGestureRecognizer) {
        let index = recognizer.view?.tag
        
        if delegate != nil {
            delegate?.didChooseColor(colors![index!])
        }
    }
    
    func createColors() {
        if colors == nil {
            if colorBtns != nil { // Clear color cans.
                for btn in colorBtns! {
                    btn.removeFromSuperview()
                }
                colorBtns?.removeAll()
                colorBtns = nil
            }
            return
        }
        
        if colorBtns == nil {
            colorBtns = [ColorSprayCan]()
            for _ in colors! {
                let btn = ColorSprayCan(frame: CGRectZero)
                btn.userInteractionEnabled = true
                self.addSubview(btn)
                colorBtns?.append(btn)
            }
        }
        
        // Layout buttons.
        let itemWidth = self.frame.width / CGFloat(App.ColorsPerRow)
        let itemHeight = self.frame.height - 30
        for (index, colorBtn) in colorBtns!.enumerate() {
            let x = CGFloat(index) * itemWidth + 3
            let f = CGRectMake(x, self.frame.height - itemHeight - 8, itemWidth, itemHeight)
            colorBtn.tag = index
            colorBtn.frame = f
            colorBtn.canColor = colors![index]
            colorBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ColorSprayCanCell.onClickColor(_:))))
        }
    }
}
