//
//  PublishViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import AVFoundation
import RNActivityView
import GraffiTab_iOS_SDK

class PublishViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var infoBtn: MaterializeRoundButton!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var streamableImageView: UIImageView!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var streamableImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCameraView()
        setupButtons()
        setupImageContainer()
        
        loadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        captureSession.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickInfo(sender: AnyObject) {
        // TODO:
    }
    
    @IBAction func onClickCreate(sender: AnyObject) {
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        let pitch = GTDeviceMotionManager.manager.pitch
        let roll = GTDeviceMotionManager.manager.roll
        let yaw = GTDeviceMotionManager.manager.yaw
        let latitude = GTLocationManager.manager.lastLocation?.coordinate.latitude
        let longitude = GTLocationManager.manager.lastLocation?.coordinate.latitude
        
        GTMeManager.createGraffiti(streamableImage!, latitude: latitude!, longitude: longitude!, pitch: pitch!, roll: roll!, yaw: yaw!, successBlock: { (response) -> Void in
            self.view.hideActivityView()
            
            Utils.runWithDelay(0.3, block: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }) { (response) -> Void in
            self.view.hideActivityView()
            
            if (response.reason == .BadRequest || response.reason == .AlreadyExists) {
                DialogBuilder.showErrorAlert("A user with these details already exists.", title: App.Title)
                return
            }
            
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
        }
    }
    
    func grabCameraFrame() {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
            }
        }
    }
    
    // MARK: - Loading
    
    func loadData() {
        streamableImageView.image = streamableImage
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
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
        createBtn.backgroundColor = UIColor(hexString: Colors.Green)
        cancelBtn.backgroundColor = UIColor.whiteColor()
        cancelBtn.tintColor = UIColor.lightGrayColor()
        infoBtn.backgroundColor = UIColor.whiteColor()
        infoBtn.tintColor = UIColor.lightGrayColor()
    }
    
    func setupImageContainer() {
        Utils.applyPublishShadowEffectToView(imageContainer)
    }
}
