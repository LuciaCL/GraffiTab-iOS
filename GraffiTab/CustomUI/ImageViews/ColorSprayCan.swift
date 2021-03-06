//
//  ColorSprayCan.swift
//  GraffiTab
//
//  Created by Georgi Christov on 19/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class ColorSprayCan: UIImageView {

    static var cache = NSCache()
    
    var overlay = UIImageView()
    var canColor: UIColor! = .blackColor() {
        didSet {
            loadColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicInit()
    }
    
    func basicInit() {
        
    }
    
    func loadColor() {
        let image = UIImage(named: "can_bottom")
        
        let hex = self.canColor.hexString(false)
        let cachedImage = ColorSprayCan.cache.objectForKey(hex) as? UIImage
        if cachedImage != nil { // We've already processed the color.
            self.alpha = 1.0
            self.image = cachedImage
        }
        else {
            self.alpha = 0.1
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                let img = self.processPixelsInImage(image!)
                ColorSprayCan.cache.setObject(img, forKey: hex)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.image = img
                    UIView.animateWithDuration(0.3, animations: {
                        self.alpha = 1.0
                    })
                })
            })
            
            self.image = image
        }
        
        self.contentMode = .ScaleAspectFit
        
        overlay.frame = self.bounds
        if overlay.image == nil {
            self.addSubview(overlay)
        }
        overlay.image = UIImage(named: "can_top")
        overlay.contentMode = .ScaleAspectFit
        overlay.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight]
    }
    
    // MARK: - UIImage operations
    
    func processPixelsInImage(inputImage: UIImage) -> UIImage {
        let inputCGImage     = inputImage.CGImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = CGImageGetWidth(inputCGImage)
        let height           = CGImageGetHeight(inputCGImage)
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)!
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage)
        
        let pixelBuffer = UnsafeMutablePointer<UInt32>(CGBitmapContextGetData(context))
        
        var currentPixel = pixelBuffer
        
        // read colors to CGFloats and convert and position to proper bit positions in UInt32
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, alpha: CGFloat = 0
        self.canColor.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        for _ in 0 ..< Int(height) {
            for _ in 0 ..< Int(width) {
                let pixel = currentPixel.memory
                if red(pixel) == 255 && green(pixel) == 0 && blue(pixel) == 0 {
                    currentPixel.memory = rgba(red: UInt8(r * 255.0), green: UInt8(g * 255.0), blue: UInt8(b * 255.0), alpha: 255)
                }
                currentPixel+=1
            }
        }
        
        let outputCGImage = CGBitmapContextCreateImage(context)
        let outputImage = UIImage(CGImage: outputCGImage!, scale: inputImage.scale, orientation: inputImage.imageOrientation)
        
        return outputImage
    }
    
    func alpha(color: UInt32) -> UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    func red(color: UInt32) -> UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    func green(color: UInt32) -> UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    func blue(color: UInt32) -> UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    func rgba(red red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> UInt32 {
        return (UInt32(alpha) << 24) | (UInt32(red) << 16) | (UInt32(green) << 8) | (UInt32(blue) << 0)
    }
}
