//
//  TuneViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 22/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import FlatUIKit

class TuneViewController: UIViewController {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var previewCanvas: UIView!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var opacitySlider: UISlider!
    
    var sizeChangedBlock: ((value: Float) -> Void)?
    var opacityChangedBlock: ((value: Float) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCanvasView()
        setupSliders()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPreviewImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onChangedSize(sender: AnyObject) {
        if sizeChangedBlock != nil {
            sizeChangedBlock!(value: sizeSlider!.value)
        }
        
        loadPreviewImage()
    }
    
    @IBAction func onChangeOpacity(sender: AnyObject) {
        if opacityChangedBlock != nil {
            opacityChangedBlock!(value: opacitySlider!.value)
        }
        
        loadPreviewImage()
    }
    
    // MARK: - Loading
    
    func loadPreviewImage() {
        previewImage.alpha = CGFloat(opacitySlider.value)
        
        let scale = CGFloat(((1.0 * sizeSlider.value) / Float(MAX_SIZE_OFFSET)) + 0.1)
        previewImage.transform = CGAffineTransformMakeScale(scale, scale)
    }
    
    // MARK: - Setup
    
    func setupCanvasView() {
        previewImage.layer.cornerRadius = previewImage.frame.height / 2
        
        Utils.applyCanvasShadowEffectToView(self.previewCanvas)
    }
    
    func setupSliders() {
        let sliderColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        let thumbColor = UIColor.lightGrayColor()
        sizeSlider.configureFatSlider(sliderColor, progressColor: sliderColor, thumbColorNormal: thumbColor, thumbColorHighlighted: thumbColor)
        opacitySlider.configureFatSlider(sliderColor, progressColor: sliderColor, thumbColorNormal: thumbColor, thumbColorHighlighted: thumbColor)
    }
}
