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
import MZFormSheetPresentationController
import JTMaterialTransition
import CocoaLumberjack

class ExploreViewController: BackButtonViewController, MKMapViewDelegate, FBClusteringManagerDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backBtn: TintButton!
    @IBOutlet weak var streetViewBtn: TintButton!
    @IBOutlet weak var gridBtn: TintButton!
    
    var toShowLatitude: CLLocationDegrees?
    var toShowLongitude: CLLocationDegrees?
    
    var transition: JTMaterialTransition?
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
            zoomMapToLocation(CLLocation(latitude: toShowLatitude!, longitude: toShowLongitude!))
            
            loadItems()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.mapStatusBarStyle!, animated: true)
        
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
            MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = !DeviceType.IS_IPAD
            MZFormSheetPresentationController.appearance().shouldCenterHorizontally = true
            MZFormSheetPresentationController.appearance().shouldCenterVertically = true
            MZFormSheetPresentationController.appearance().shouldDismissOnBackgroundViewTap = true
            
            let nav = self.storyboard!.instantiateViewControllerWithIdentifier("ClusterViewController") as! UINavigationController
            let formSheetController = MZFormSheetPresentationViewController(contentViewController: nav)
            if DeviceType.IS_IPAD {
                formSheetController.presentationController?.contentViewSize = CGSizeMake(400, 450)
            }
            else {
                formSheetController.presentationController?.contentViewSize = CGSizeMake(300, 344)
            }
            formSheetController.contentViewControllerTransitionStyle = .SlideFromBottom
            
            let vc = nav.viewControllers.first as! ClusterViewController
            vc.items = streamables
            
            self.presentViewController(formSheetController, animated: true, completion: nil)
        }
    }
    
    func openAnnotationView(sender: UITapGestureRecognizer) {
        let annotationView = sender.view as! MKPinAnnotationView
        let streamableAnnotation = annotationView.annotation as! StreamableAnnotation
        
        ViewControllerUtils.showStreamableDetails(streamableAnnotation.streamable!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
    }
    
    // MARK: - Loading
    
    func loadItems() {
        if mapView == nil {
            return
        }
        
        let location = toShowLatitude != nil && toShowLongitude != nil ? CLLocation(latitude: toShowLatitude!, longitude: toShowLongitude!) : (mapView.userLocation.location != nil ? mapView.userLocation.location : nil)
        
        if location != nil {
            let latitude = location?.coordinate.latitude
            let longitude = location?.coordinate.longitude
            
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Searchin for location:\nLatitude: \(latitude)\nLongitude: \(longitude)")
            
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
            
            GTStreamableManager.searchForLocation(latitude!, longitude: longitude!, radius: AppConfig.sharedInstance.locationRadius, successBlock: { (response) -> Void in
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
                let annotation = StreamableAnnotation()
                annotation.streamable = streamable
                annotation.title = streamable.user?.getFullName()
                annotation.coordinate = CLLocationCoordinate2DMake(streamable.latitude!, streamable.longitude!)
                
                items.append(streamable)
                annotations.append(annotation)
            }
        }
    }
    
    func finalizeLoad() {
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
        })
    }
    
    // MARK: - MKMapViewDelegate
    
    func zoomMapToLocation(location: CLLocation) {
        if mapView == nil {
            return
        }
        
        mapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 50, 50)
        mapView.camera.pitch = 65
    }
    
    func didEndMapRegionChange() {
        if mapView == nil {
            return
        }

        loadItems()
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if toShowLatitude == nil && toShowLongitude == nil { // Only refresh-on-follow if the explorer is not showing an external location.
            zoomMapToLocation(userLocation.location!)
            
            doClusterAnnotations()
            
            if refreshTimer != nil { // Kill previous timer.
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
            
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(didEndMapRegionChange), userInfo: nil, repeats: false)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            let reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            return clusterView
        }
        else if annotation.isKindOfClass(StreamableAnnotation) {
            let reuseId = "Streamable"
            let streamableAnnotation = annotation as! StreamableAnnotation
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annotationView == nil {
                let pinAnnotationView = MKPinAnnotationView(annotation: streamableAnnotation, reuseIdentifier: reuseId)
                pinAnnotationView.canShowCallout = true
                pinAnnotationView.animatesDrop = false
                pinAnnotationView.pinTintColor = AppConfig.sharedInstance.theme?.primaryColor
                annotationView = pinAnnotationView
            }
            
            return annotationView
        }
        
        return nil
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if view.isKindOfClass(FBAnnotationClusterView) { // Select cluster.
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
        else if view.isKindOfClass(MKPinAnnotationView.classForCoder()) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openAnnotationView(_:)))
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if view.isKindOfClass(MKPinAnnotationView.classForCoder()) {
            view.gestureRecognizers?.forEach({ (recognizer) in
                view.removeGestureRecognizer(recognizer)
            })
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
        let items = [backBtn, streetViewBtn, gridBtn]
        
        for view in items {
            view.applyMaterializeStyle(0.2)
        }
        
        backBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        streetViewBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        gridBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
    }
    
    func setupMapView() {
        mapView.rotateEnabled = true
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.showsBuildings = false
        mapView.showsTraffic = false
        mapView.showsCompass = false
        mapView.showsUserLocation = (CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse)
    }
    
    func setupTransition() {
        transition = JTMaterialTransition(animatedView: streetViewBtn)
    }
}
