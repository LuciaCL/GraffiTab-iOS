//
//  ViewController+ImagePicker.swift
//  GraffiTab
//
//  Created by Georgi Christov on 22/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    func askForImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        UIActionSheet.showInView(view, withTitle: "What would you like to do?", cancelButtonTitle: "Cancel", destructiveButtonTitle: "Remove image", otherButtonTitles: ["Choose from gallery", "Take new"], tapBlock: { (actionSheet, index) in
            if index == 0 {
                self.didChooseImage(nil)
            }
            else if index == 1 {
                self.chooseFromGallery(imagePicker)
            }
            else if index == 2 {
                self.takeNew(imagePicker)
            }
        })
    }
    
    func chooseFromGallery(imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            print("DEBUG: Source type .PhotoLibrary not available")
        }
    }
    
    func takeNew(imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            print("DEBUG: Source type .Camera not available")
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
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let cropController = TOCropViewController(image: pickedImage)
            cropController.delegate = self
            cropController.cropView.cropBoxResizeEnabled = false
            presentViewController(cropController, animated: true, completion: {
                cropController.cropView.setAspectLockEnabledWithAspectRatio(self.cropAspectRatio(), animated: true)
            })
        }
    }
    
    // MARK: - TOCropViewControllerDelegate
    
    public func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismissViewControllerAnimated(true, completion: nil)
        
        didChooseImage(image)
    }
}
