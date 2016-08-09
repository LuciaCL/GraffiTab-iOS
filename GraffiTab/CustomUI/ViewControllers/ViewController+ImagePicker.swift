//
//  ViewController+ImagePicker.swift
//  GraffiTab
//
//  Created by Georgi Christov on 22/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CocoaLumberjack

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    func askForImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        let actionSheet = buildActionSheet("Choose image source")
        actionSheet.addButtonWithTitle("Choose from photos", image: UIImage(named: "ic_collections_white"), type: .Default) { (sheet) in
            self.chooseFromGallery(imagePicker)
        }
        actionSheet.addButtonWithTitle("Take a picture", image: UIImage(named: "ic_photo_camera_white"), type: .Default) { (sheet) in
            self.takeNew(imagePicker)
        }
        actionSheet.addButtonWithTitle("Remove image", image: UIImage(named: "ic_clear_white"), type: .Destructive) { (sheet) in
            DialogBuilder.showYesNoAlert(self, status: "Are you sure you want to clear this image?", title: App.Title, yesTitle: "Yes, clear it!", noTitle: "Cancel", yesAction: { 
                self.didChooseImage(nil)
            }, noAction: { 
                
            })
        }
        actionSheet.show()
    }
    
    func chooseFromGallery(imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            DDLogError("[\(NSStringFromClass(self.dynamicType))] Source type .PhotoLibrary not available")
        }
    }
    
    func takeNew(imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            DDLogError("[\(NSStringFromClass(self.dynamicType))] Source type .Camera not available")
        }
    }
    
    func didChooseImage(image: UIImage?) {
        if image != nil { // Choosing a new image.
            
        }
        else { // Removing an image.
            
        }
    }
    
    func cropAspectRatio() -> CGSize {
        let view = self.view;
        return CGSizeMake(view.frame.size.width, view.frame.size.width / (view.frame.size.width / view.frame.size.height))
    }
    
    func resizingEnabled() -> Bool {
        return true
    }
    
    func resetEnabled() -> Bool {
        return true
    }
    
    func rotationEnabled() -> Bool {
        return true
    }
    
    func startCropperForImage(pickedImage: UIImage) {
        let cropController = TOCropViewController(image: pickedImage)
        cropController.delegate = self
        if !resizingEnabled() {
            cropController.cropView.cropBoxResizeEnabled = false
            cropController.aspectRatioLocked = true
        }
        if !resetEnabled() {
            cropController.cropView.delegate = nil
        }
        if !rotationEnabled() {
            cropController.rotateClockwiseButtonHidden = true
            cropController.rotateButtonsHidden = true
        }
        
        presentViewController(cropController, animated: true, completion: {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
            
            cropController.cropView.setAspectLockEnabledWithAspectRatio(self.cropAspectRatio(), animated: true)
        })
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        if var pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if pickedImage.size.width > CGFloat(Image.MaxImageWidth) {
                pickedImage = pickedImage.resizeWithWidth(CGFloat(Image.MaxImageWidth))!
            }
            self.startCropperForImage(pickedImage)
        }
    }
    
    // MARK: - TOCropViewControllerDelegate
    
    public func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        
        cropViewController.dismissViewControllerAnimated(true, completion: nil)
        
        didChooseImage(image)
    }
    
    public func cropViewController(cropViewController: TOCropViewController!, didFinishCancelled cancelled: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        
        cropViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
