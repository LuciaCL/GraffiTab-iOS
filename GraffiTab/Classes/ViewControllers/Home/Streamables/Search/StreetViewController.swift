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
import CoreGraphics

class StreetViewController: UIViewController, VideoSourceDelegate {

    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var updateTimer: NSTimer?
    var initialLoad = false
    var items = [GTStreamable]()
    var imageDownloadTasks = [NSURLSessionTask]()
    var imageViews = [UIImageView]()
    
    // OpenCV
    var videoSource: VideoSource?
    var arView: ARView?
    var openCVWrapper: OpenCVWrapper?
    var m_targetViewWidth: CGFloat?
    var m_targetViewHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupButtons()
        setupOpenCVWrapper()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(loadItems), userInfo: nil, repeats: true)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
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
            
            loadItems()
        }
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        videoSource!.captureSession.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Loading
    
    func loadItems() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Refreshing streamables in street view")
        
//        let location = GTLocationManager.manager.lastLocation
//        
//        if location != nil {
//            let center = location!.coordinate
//            
//            // Search for items within 1km radius of the user's current location.
//            let region = MKCoordinateRegionMakeWithDistance(center, App.Radius, App.Radius)
//            
//            // Obtain bounding box GPS coordinates.
//            var northEastCorner: CLLocationCoordinate2D = CLLocationCoordinate2D()
//            northEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0)
//            northEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0)
//            
//            var southWestCorner: CLLocationCoordinate2D = CLLocationCoordinate2D()
//            southWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0)
//            southWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0)
//            
//            GTStreamableManager.searchForLocation(northEastCorner.latitude, neLongitude: northEastCorner.longitude, swLatitude: southWestCorner.latitude, swLongitude: southWestCorner.longitude, successBlock: {(response) in
//                let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
//                
//                self.processAnnotations(listItemsResult.items!)
//                self.downloadImagesAndRefresh()
//            }, failureBlock: {(response) in
//                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
//            })
//        }
//        else {
//            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] No previous location detected. Attempting to locate")
//        }
    }
    
//    func processAnnotations(streamables: [GTStreamable]) {
//        for streamable in streamables {
//            if items.contains({$0.id == streamable.id}) == false {
//                let imageView = UIImageView()
//                imageView.contentMode = .ScaleAspectFit
//                imageView.backgroundColor = UIColor.darkGrayColor()
//                imageView.frame = CGRectZero
//                self.view.addSubview(imageView)
//                
//                items.append(streamable)
//                imageViews.append(imageView)
//            }
//        }
//    }
//    
//    func downloadImagesAndRefresh() {
//        // Cancel all previous tasks
//        for task in imageDownloadTasks {
//            task.cancel()
//        }
//        imageDownloadTasks.removeAll()
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            for streamable in self.items {
//                // Success block.
//                let successBlock = {(url: NSURL, image: UIImage, streamable: GTStreamable) in
//                    dispatch_async( dispatch_get_main_queue(), {
//                        // Update image thumbnail.
////                        let thumbnail = self.getThumbnailAnnotationForStreamable(annotation.streamable!)
////                        thumbnail.image = image
////                        annotation.updateThumbnail(thumbnail, animated: true)
//                    })
//                }
//                
//                // Fetch image either from cache or web.
//                let url = NSURL(string: (streamable.asset?.link)!)!
//                let cachedImage = self.imageCache.objectForKey(url) as? UIImage
//                
//                if cachedImage != nil { // Use cached image.
//                    DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Cache hit image for url \(url)")
//                    
//                    successBlock(url, cachedImage!, streamable)
//                }
//                else { // Download image.
//                    let session = NSURLSession.sharedSession()
//                    let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) in
//                        if error == nil {
//                            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Downloaded image for url \(url)")
//                            
//                            let image = UIImage(data: data!)
//                            
//                            // Add image to cache.
//                            self.imageCache.setObject(image!, forKey: url)
//                            
//                            successBlock(url, image!, streamable)
//                        }
//                        else {
//                            DDLogError("[\(NSStringFromClass(self.dynamicType))] Failed to load image for url \(url)")
//                        }
//                    })
//                    self.imageDownloadTasks.append(task)
//                    task.resume()
//                }
//            }
//        });
//    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: - VideoSourceDelegate
    
    func frameReady(frame: VideoFrame) {
        dispatch_sync(dispatch_get_main_queue()) { 
            // (1) Construct CGContextRef from VideoFrame
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue)
            let newContext = CGBitmapContextCreate(frame.data, frame.width, frame.height, 8, frame.stride, colorSpace, bitmapInfo.rawValue)
            
            // (2) Construct CGImageRef from CGContextRef
            let newImage = CGBitmapContextCreateImage(newContext)
            
            // (3) Construct UIImage from CGImageRef
            let image = UIImage(CGImage: newImage!)
            self.cameraView.image = image
        }
        
        openCVWrapper?.scanFrame(frame)
    }
    
    // MARK: - Setup
 
    func setupOpenCVWrapper() {
        videoSource = VideoSource()
        videoSource?.delegate = self
        videoSource?.startWithDevicePosition(.Back)
        
        let trackerImage = UIImage(named: "target.jpg")
        
        // SetupARView
        arView = ARView(frame: CGRectMake(0, 0, trackerImage!.size.width, trackerImage!.size.height))
        self.view.addSubview(arView!)
        self.arView?.hide()
        
        m_targetViewWidth = arView!.frame.size.width
        m_targetViewHeight = arView!.frame.size.height
        
        // Configure OpenCVWrapper.
        openCVWrapper = OpenCVWrapper()
        openCVWrapper?.createPatternMatcherWithTrackerImage(trackerImage)
        openCVWrapper?.arView = arView
        openCVWrapper?.m_targetViewWidth = m_targetViewWidth!
        openCVWrapper?.m_targetViewHeight = m_targetViewHeight!
    }
    
    func setupButtons() {
        cancelBtn.backgroundColor = UIColor.whiteColor()
        cancelBtn.tintColor = UIColor.lightGrayColor()
    }
}
