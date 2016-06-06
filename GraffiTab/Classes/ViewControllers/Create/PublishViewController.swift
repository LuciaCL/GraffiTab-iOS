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
import CocoaLumberjack

protocol PublishDelegate {
    
    func didPublish()
    func didCancel()
}

class PublishViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var infoBtn: MaterializeRoundButton!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var streamableImageView: UIImageView!
    
    var toEdit: GTStreamable?
    
    var delegate: PublishDelegate?
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var streamableImage: UIImage?
    var loadedCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        if self.delegate != nil {
            self.delegate?.didCancel()
        }
        
        captureSession.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickInfo(sender: AnyObject) {
        // TODO:
    }
    
    @IBAction func onClickCreate(sender: AnyObject) {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Attempting to publish")
        
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        var pitch = GTDeviceMotionManager.manager.pitch
        var roll = GTDeviceMotionManager.manager.roll
        var yaw = GTDeviceMotionManager.manager.yaw
        let latitude = GTLocationManager.manager.lastLocation?.coordinate.latitude
        let longitude = GTLocationManager.manager.lastLocation?.coordinate.longitude
        
        if pitch == nil {
            pitch = 0.0
        }
        if roll == nil {
            roll = 0.0
        }
        if yaw == nil {
            yaw = 0.0
        }
        
        let successBlock = {
            self.view.hideActivityView()
            
            Utils.runWithDelay(0.3, block: {
                if self.delegate != nil {
                    self.delegate?.didPublish()
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        let failBlock = { (response: GTResponseObject) in
            self.view.hideActivityView()
            
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
        }
        
        if toEdit != nil {
            GTMeManager.editGraffiti(toEdit!.id!, image: streamableImage!, latitude: latitude!, longitude: longitude!, pitch: pitch!, roll: roll!, yaw: yaw!, successBlock: { (response) -> Void in
                successBlock()
            }) { (response) -> Void in
                failBlock(response)
            }
        }
        else {
            GTMeManager.createGraffiti(streamableImage!, latitude: latitude!, longitude: longitude!, pitch: pitch!, roll: roll!, yaw: yaw!, successBlock: { (response) -> Void in
                successBlock()
            }) { (response) -> Void in
                failBlock(response)
            }
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
        return [.Portrait]
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
        infoBtn.backgroundColor = UIColor.whiteColor()
    }
    
    func setupImageContainer() {
        Utils.applyPublishShadowEffectToView(imageContainer)
    }
}
