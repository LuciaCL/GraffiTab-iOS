//
//  StreetViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 24/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import AVFoundation
import GraffiTab_iOS_SDK

class StreetViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var loadedCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GTDeviceMotionManager.manager.startMotionUpdates()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        GTDeviceMotionManager.manager.stopMotionUpdates()
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loadedCamera {
            loadedCamera = true
            
            setupCameraView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        captureSession.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Loading
    
    
    
    // MARK: - Setup
    
    func setupCameraView() {
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            do {
                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                captureSession.startRunning()
                stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                
                if captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addOutput(stillImageOutput)
                }
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                if previewLayer != nil {
                    previewLayer!.bounds = view.bounds
                    previewLayer!.position = CGPointMake(view.bounds.midX, view.bounds.midY)
                    previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                    cameraView.layer.addSublayer(previewLayer!)
                }
            } catch (_) {
                
            }
        }
    }
    
    func setupButtons() {
        cancelBtn.backgroundColor = UIColor.whiteColor()
        cancelBtn.tintColor = UIColor.lightGrayColor()
    }
}
