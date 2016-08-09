//
//  ExploreViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import MapKit
import GraffiTab_iOS_SDK
import FBAnnotationClusteringSwift
import JPSThumbnailAnnotation
import MZFormSheetPresentationController
import JTMaterialTransition
import CocoaLumberjack

class ExploreViewController: BackButtonViewController, UITextFieldDelegate, MKMapViewDelegate, FBClusteringManagerDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var backBtn: TintButton!
    @IBOutlet weak var searchBtn: TintButton!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var terrainBtn: TintButton!
    @IBOutlet weak var streetViewBtn: TintButton!
    
    var toShowLatitude: CLLocationDegrees?
    var toShowLongitude: CLLocationDegrees?
    var toShowUser: GTUser?
    
    var transition: JTMaterialTransition?
    var isMovedByTap = false
    var isSearching = false
    var showedFirstUserLocation = false
    var items = [GTStreamable]()
    var annotations = [StreamableAnnotation]()
    var imageDownloadTasks = [NSURLSessionTask]()
    var refreshTimer: NSTimer?
    let clusteringManager = FBClusteringManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        setupMapView()
        setupTransition()
        
        if toShowLatitude != nil && toShowLongitude != nil {
            centerToLocation(CLLocation(latitude: toShowLatitude!, longitude: toShowLongitude!))
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        if self.navigationController != nil && !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        let destroy = {
            self.mapView.mapType = self.mapView.mapType == .Standard ? .Satellite : .Standard
            self.mapView.delegate = nil
            self.mapView.removeFromSuperview()
            self.mapView = nil
        }
        
        if self.navigationController?.viewControllers.count <= 1 { // We're running in a container so show a close button.
            self.dismissViewControllerAnimated(true, completion: {
                destroy()
            })
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
            
            Utils.runWithDelay(0.3, block: destroy)
        }
    }
    
    @IBAction func onClickGrid(sender: AnyObject) {
        if items.count > 0 {
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("map_cluster", label: nil)
            
            openClusterView(items)
        }
    }
    
    @IBAction func onClickLocation(sender: AnyObject) {
        if mapView == nil {
            return
        }
        
        if mapView.userLocation.location != nil {
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("center_to_location", label: nil)
            
            centerToLocation(mapView.userLocation.location!)
        }
    }
    
    @IBAction func onClickSearch(sender: AnyObject) {
        isSearching = !isSearching
        
        let searchWidth: CGFloat
        if isSearching {
            searchField.text = ""
            searchWidth = 220
        }
        else {
            searchWidth = 40
        }
        
        searchWidthConstraint.constant = searchWidth
        searchContainer.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.3, animations: { 
            self.searchContainer.layoutIfNeeded()
        }) { (finished) in
            if finished {
                if self.isSearching {
                    self.searchField.becomeFirstResponder()
                }
                else {
                    self.view.endEditing(true)
                }
            }
        }
    }
    
    @IBAction func onClickTerrain(sender: AnyObject) {
        if mapView == nil {
            return
        }
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("change_map_terrain", label: nil)
        
        if mapView.mapType == .Satellite {
            mapView.mapType = .Standard
            terrainBtn.tintColor = UIColor(hexString: "#e0e0e0")
            
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
        else {
            mapView.mapType = .Satellite
            terrainBtn.tintColor = UIColor(hexString: Colors.Main)
            
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        }
    }
    
    @IBAction func onClickStreetView(sender: AnyObject) {
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("street_view", label: nil)
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("StreetViewController")
        
        vc.modalPresentationStyle = .Custom
        vc.transitioningDelegate = self
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func openClusterView(streamables: [GTStreamable]) {
        if streamables.count > 0 {
            MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
            MZFormSheetPresentationController.appearance().shouldCenterHorizontally = true
            MZFormSheetPresentationController.appearance().shouldCenterVertically = true
            MZFormSheetPresentationController.appearance().shouldDismissOnBackgroundViewTap = true
            
            let nav = self.storyboard!.instantiateViewControllerWithIdentifier("ClusterViewController") as! UINavigationController
            let formSheetController = MZFormSheetPresentationViewController(contentViewController: nav)
            formSheetController.presentationController?.contentViewSize = CGSizeMake(300, 344)
            formSheetController.contentViewControllerTransitionStyle = .SlideFromBottom
            
            let vc = nav.viewControllers.first as! ClusterViewController
            vc.items = streamables
            
            self.presentViewController(formSheetController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Loading
    
    func loadItems() {
        if mapView == nil {
            return
        }
        
        // First we need to calculate the corners of the map so we get the points.
        let nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
        let swPoint = CGPointMake(mapView.bounds.origin.x, mapView.bounds.origin.y + mapView.bounds.size.height);
        
        // Then transform those point into lat, lng values.
        let neCoord = mapView.convertPoint(nePoint, toCoordinateFromView: mapView)
        let swCoord = mapView.convertPoint(swPoint, toCoordinateFromView: mapView)
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Map bounding rectangle is \(neCoord), + \(swCoord)")
        
        let successBlock = {(response: GTResponseObject) -> Void in
            let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
            
            self.items.removeAll()
            self.annotations.removeAll()
            
            self.processAnnotations(listItemsResult.items!)
            self.finalizeLoad()
        }
        let failureBlock = {(response: GTResponseObject) -> Void in
            self.finalizeLoad()
            
            DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, reason: response.error.reason)
        }
        
        if toShowUser != nil {
            GTUserManager.getUserStreamablesForLocation(toShowUser!.id!, neLatitude: neCoord.latitude, neLongitude: neCoord.longitude, swLatitude: swCoord.latitude, swLongitude: swCoord.longitude, successBlock: { (response) -> Void in
                successBlock(response)
            }) { (response) -> Void in
                failureBlock(response)
            }
        }
        else {
            GTStreamableManager.searchForLocation(neCoord.latitude, neLongitude: neCoord.longitude, swLatitude: swCoord.latitude, swLongitude: swCoord.longitude, successBlock: { (response) -> Void in
                successBlock(response)
            }) { (response) -> Void in
                failureBlock(response)
            }
        }
    }
    
    func processAnnotations(streamables: [GTStreamable]) {
        for streamable in streamables {
            if items.contains({
                $0.id == streamable.id
            }) == false {
                let thumbnail = getThumbnailAnnotationForStreamable(streamable)
                let annotation = StreamableAnnotation(thumbnail: thumbnail)
                annotation.streamable = streamable
                
                items.append(streamable)
                annotations.append(annotation)
            }
        }
    }
    
    func finalizeLoad() {
        searchBtn.tintColor = UIColor(hexString: Colors.Main)
        loadingIndicator.stopAnimating()
        
        clusteringManager.setAnnotations(annotations)
        
        // Cluster annotations.
        doClusterAnnotations()
    }
    
    func doClusterAnnotations() {
        if mapView == nil {
            return
        }
        
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth: Double = self.mapView.visibleMapRect.size.width
            let scale: Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
            
            self.downloadImagesAndRefresh()
        })
    }
    
    func downloadImagesAndRefresh() {
        // Cancel all previous tasks
        for task in imageDownloadTasks {
            task.cancel()
        }
        imageDownloadTasks.removeAll()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for annotation in self.annotations {
                // Success block.
                let successBlock = {(url: NSURL, image: UIImage, annotation: StreamableAnnotation) in
                    dispatch_async( dispatch_get_main_queue(), {
                        // Update image thumbnail.
                        let thumbnail = self.getThumbnailAnnotationForStreamable(annotation.streamable!)
                        thumbnail.image = image
                        annotation.updateThumbnail(thumbnail, animated: true)
                    })
                }
                
                // Fetch image either from cache or web.
                let url = NSURL(string: (annotation.streamable?.asset?.thumbnail)!)!
                let cachedImage = AppImageCache.sharedInstance.queryMemoryCachedImage(url.absoluteString)
                
                if cachedImage != nil { // Use cached image.
                    DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Cache hit image for url \(url)")
                    
                    successBlock(url, cachedImage!, annotation)
                }
                else { // Download image.
                    let session = NSURLSession.sharedSession()
                    let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) in
                        if error == nil {
                            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Downloaded image for url \(url)")
                            
                            let image = UIImage(data: data!)
                            
                            // Add image to cache.
                            AppImageCache.sharedInstance.cacheImage(url.absoluteString, image: image)
                            
                            successBlock(url, image!, annotation)
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
    
    func getThumbnailAnnotationForStreamable(streamable: GTStreamable) -> StreamableThumbnail {
        let thumbnail = StreamableThumbnail()
        thumbnail.title = streamable.user?.getFullName()
        thumbnail.subtitle = streamable.user?.getMentionUsername()
        thumbnail.coordinate = CLLocationCoordinate2D(latitude: streamable.latitude!, longitude: streamable.longitude!)
        thumbnail.disclosureBlock = {
            ViewControllerUtils.showStreamableDetails(streamable, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
        }
        
        return thumbnail
    }
    
    // MARK: - Search
    
    func searchLocationForAddress(address: String) {
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = address
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            self.view.hideActivityView()
            
            let placemarks = response?.mapItems
            if placemarks?.count <= 0 {
                DialogBuilder.showOKAlert(self, status: "No locations found for this address.", title: App.Title)
            }
            
            if placemarks?.count > 1 { // More than 1 address matches found. Ask user which one to use.
                DialogBuilder.showOKAlert(self, status: "Multiple matches found. The first one will be used.", title: App.Title, okAction: { 
                    let mapItem = placemarks?.first
                    self.zoomMapToLocation(mapItem!.placemark.location!)
                })
            }
            else { // Only one match found, so use it.
                let mapItem = placemarks?.first
                self.zoomMapToLocation(mapItem!.placemark.location!)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.text?.characters.count > 0 {
            searchLocationForAddress(textField.text!)
        }
        
        return true
    }
    
    // MARK: - MKMapViewDelegate
    
    func centerToLocation(location: CLLocation) {
        zoomMapToLocation(location)
    }
    
    func zoomMapToLocation(location: CLLocation) {
        if mapView == nil {
            return
        }
        
        let delta = toShowUser != nil ? 10 : 0.2
        
        var region = MKCoordinateRegion()
        region.center = location.coordinate
        region.span.latitudeDelta = delta
        region.span.longitudeDelta = delta
        mapView.setRegion(region, animated: true)
    }
    
    func didEndMapRegionChange() {
        if mapView == nil {
            return
        }
        
        if isMovedByTap {
            searchBtn.tintColor = UIColor(hexString: Colors.Main)
            loadingIndicator.stopAnimating()
            
            isMovedByTap = false
            return
        }
        
        if mapView.region.span.latitudeDelta > 11.0 || mapView.region.span.longitudeDelta > 11.0 {
            searchBtn.tintColor = UIColor(hexString: Colors.Main)
            loadingIndicator.stopAnimating()
            
            var region = mapView.region
            region.span = MKCoordinateSpanMake(10.0, 10.0)
            mapView.setRegion(region, animated: true)
        }
        else {
            loadItems()
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !showedFirstUserLocation {
            if toShowLatitude == nil && toShowLongitude == nil {
                centerToLocation(userLocation.location!)
            }
        }
        
        showedFirstUserLocation = true
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        searchBtn.tintColor = UIColor(hexString: "#efefef")
        if !loadingIndicator!.isAnimating() {
            loadingIndicator.startAnimating()
        }
        
        doClusterAnnotations()
        
        if refreshTimer != nil { // Kill previous timer.
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(didEndMapRegionChange), userInfo: nil, repeats: false)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            return clusterView
        }
        else if annotation.isKindOfClass(StreamableAnnotation) {
            let thumbnailAnnotation = (annotation as! StreamableAnnotation).annotationViewInMap(mapView) as! JPSThumbnailAnnotationView
            
            // Remove layer to optimize map panning.
            let layer = thumbnailAnnotation.layer.sublayers?.first
            layer?.shadowOpacity = 0.0
            layer?.shadowRadius = 0.0
            layer?.shadowColor = nil
            
            for view in thumbnailAnnotation.subviews {
                if view.isKindOfClass(UIImageView) {
                    (view as? UIImageView)?.contentMode = .ScaleAspectFill
                    (view as? UIImageView)?.clipsToBounds = true
                }
            }
            
            return thumbnailAnnotation
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if view.isKindOfClass(JPSThumbnailAnnotationView) { // Select single item.
            isMovedByTap = true
            
            return (view as! JPSThumbnailAnnotationView).didSelectAnnotationViewInMap(mapView)
        }
        else if view.isKindOfClass(FBAnnotationClusterView) { // Select cluster.
            // Process cluster click.
            let annotation = view.annotation as! FBAnnotationCluster
            var streamables = [GTStreamable]()
            for streamableAnnotation in annotation.annotations {
                streamables.append((streamableAnnotation as! StreamableAnnotation).streamable!)
            }
            if streamables.count > 0 {
                openClusterView(streamables)
            }
            
            // Deselect annotation so that it can be clicked again.
            Utils.runWithDelay(0.5, block: {
                for annotation in self.mapView.selectedAnnotations {
                    self.mapView.deselectAnnotation(annotation, animated: false)
                }
            })
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if view.isKindOfClass(JPSThumbnailAnnotationView) {
            return (view as! JPSThumbnailAnnotationView).didDeselectAnnotationViewInMap(mapView)
        }
    }
    
    // MARK: - FBClusteringManagerDelegate
    
    func cellSizeFactorForCoordinator(coordinator: FBClusteringManager) -> CGFloat {
        return 1.0
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.reverse = false
        
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.reverse = true
        
        return transition
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        terrainBtn.tintColor = UIColor(hexString: "#e0e0e0")
        
        let items = [backBtn, bottomContainer, searchContainer, terrainBtn, streetViewBtn]
        
        for view in items {
            Utils.applyShadowEffectToView(view)
            view.layer.cornerRadius = 5.0
        }
    }
    
    func setupMapView() {
        mapView.rotateEnabled = false
        mapView.showsUserLocation = (CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse)
    }
    
    func setupTransition() {
        transition = JTMaterialTransition(animatedView: streetViewBtn)
    }
}
