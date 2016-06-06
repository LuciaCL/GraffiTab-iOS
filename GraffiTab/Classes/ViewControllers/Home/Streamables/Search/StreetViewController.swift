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
import CocoaLumberjack

class StreetViewController: UIViewController, MotionDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var updateTimer: NSTimer?
    var imageCache = NSCache()
    var initialLoad = false
    var items = [GTStreamable]()
    var imageDownloadTasks = [NSURLSessionTask]()
    var imageViews = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GTDeviceMotionManager.manager.delegate = self
        GTDeviceMotionManager.manager.startMotionUpdates()
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(loadItems), userInfo: nil, repeats: true)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        GTDeviceMotionManager.manager.delegate = nil
        GTDeviceMotionManager.manager.stopMotionUpdates()
        
        if updateTimer != nil {
            updateTimer?.invalidate()
            updateTimer = nil
        }
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initialLoad {
            initialLoad = true
            
            setupCameraView()
            
            loadItems()
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
    
    func loadItems() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Refreshing streamables in street view")
        
        let location = GTLocationManager.manager.lastLocation
        
        if location != nil {
            let center = location!.coordinate
            
            // Search for items within 1km radius of the user's current location.
            let region = MKCoordinateRegionMakeWithDistance(center, App.Radius, App.Radius)
            
            // Obtain bounding box GPS coordinates.
            var northEastCorner: CLLocationCoordinate2D = CLLocationCoordinate2D()
            northEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0)
            northEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0)
            
            var southWestCorner: CLLocationCoordinate2D = CLLocationCoordinate2D()
            southWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0)
            southWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0)
            
            GTStreamableManager.searchForLocation(northEastCorner.latitude, neLongitude: northEastCorner.longitude, swLatitude: southWestCorner.latitude, swLongitude: southWestCorner.longitude, successBlock: {(response) in
                let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
                
                self.processAnnotations(listItemsResult.items!)
                self.downloadImagesAndRefresh()
            }, failureBlock: {(response) in
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
            })
        }
        else {
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] No previous location detected. Attempting to locate")
        }
    }
    
    func processAnnotations(streamables: [GTStreamable]) {
        for streamable in streamables {
            if items.contains({$0.id == streamable.id}) == false {
                let imageView = UIImageView()
                imageView.contentMode = .ScaleAspectFit
                imageView.backgroundColor = UIColor.darkGrayColor()
                imageView.frame = CGRectZero
                self.view.addSubview(imageView)
                
                items.append(streamable)
                imageViews.append(imageView)
            }
        }
    }
    
    func downloadImagesAndRefresh() {
        // Cancel all previous tasks
        for task in imageDownloadTasks {
            task.cancel()
        }
        imageDownloadTasks.removeAll()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for streamable in self.items {
                // Success block.
                let successBlock = {(url: NSURL, image: UIImage, streamable: GTStreamable) in
                    dispatch_async( dispatch_get_main_queue(), {
                        // Update image thumbnail.
//                        let thumbnail = self.getThumbnailAnnotationForStreamable(annotation.streamable!)
//                        thumbnail.image = image
//                        annotation.updateThumbnail(thumbnail, animated: true)
                    })
                }
                
                // Fetch image either from cache or web.
                let url = NSURL(string: (streamable.asset?.link)!)!
                let cachedImage = self.imageCache.objectForKey(url) as? UIImage
                
                if cachedImage != nil { // Use cached image.
                    DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Cache hit image for url \(url)")
                    
                    successBlock(url, cachedImage!, streamable)
                }
                else { // Download image.
                    let session = NSURLSession.sharedSession()
                    let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) in
                        if error == nil {
                            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Downloaded image for url \(url)")
                            
                            let image = UIImage(data: data!)
                            
                            // Add image to cache.
                            self.imageCache.setObject(image!, forKey: url)
                            
                            successBlock(url, image!, streamable)
                        }
                        else {
                            DDLogError("[\(NSStringFromClass(self.dynamicType))] Failed to load image for url \(url)")
                        }
                    })
                    self.imageDownloadTasks.append(task)
                    task.resume()
                }
            }
        });
    }
    
    // MARK: - MotionDelegate
    
    func didReceiveMotionUpdate(pitch: CGFloat, roll: CGFloat, yaw: CGFloat) {
        for (index, streamable) in items.enumerate() {
            var imageView = imageViews[index]
            let viewCenter = self.view.center
            
            // Calculate offsets.
//            let offsetXDegrees = CGFloat(streamable.yaw!) - yaw
            let offsetYDegrees = CGFloat(streamable.pitch!) - pitch
//            let offsetZDegrees = CGFloat(streamable.roll!) - roll
            
            // Apply transformations to the view's frame.
            var frame = imageView.frame
            
            // TODO: Calculate size based on how far the user is from the graffiti.
            frame.size.width = 100
            frame.size.height = 100
            
            imageView.frame = frame
            
            // Calculate position based on x/y offsets.
            var imageCenter = imageView.center
            imageCenter.x = /*viewCenter.x - (offsetZDegrees * 2)*/viewCenter.x
            imageCenter.y = viewCenter.y - (offsetYDegrees * 2)
            imageView.center = imageCenter
            
            // TODO: Calculate 3D rotation based on z offset.
            
            break
        }
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
        cancelBtn.backgroundColor = UIColor.whiteColor()
        cancelBtn.tintColor = UIColor.lightGrayColor()
    }
}
