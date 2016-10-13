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

class ExploreViewController: BackButtonViewController, MKMapViewDelegate, FBClusteringManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backBtn: TintButton!
    @IBOutlet weak var gridBtn: TintButton!
    @IBOutlet weak var locateBtn: TintButton!
    @IBOutlet weak var bottomButtonsContainer: UIView!
    
    var toShowLatitude: CLLocationDegrees?
    var toShowLongitude: CLLocationDegrees?
    
    var items = [GTStreamable]()
    var annotations = [StreamableAnnotation]()
    var refreshTimer: NSTimer?
    let clusteringManager = FBClusteringManager()
    var initialMapSetup = false
    var modifyingMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        setupMapView()
        
        if toShowLatitude != nil && toShowLongitude != nil { // Center map to custom location.
            zoomMapToLocation(CLLocation(latitude: toShowLatitude!, longitude: toShowLongitude!))
        }
        
        Utils.runWithDelay(1) {
            self.startTimer()
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
    
    @IBAction func onClickLocate(sender: AnyObject) {
        if mapView.userLocation.location != nil {
            mapView.camera.centerCoordinate = mapView.userLocation.coordinate
            doClusterAnnotations()
        }
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        let destroy = {
            self.stopTimer()
            
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
        
        let mapCenter = mapView.centerCoordinate
        let location = toShowLatitude != nil && toShowLongitude != nil ? CLLocation(latitude: toShowLatitude!, longitude: toShowLongitude!) : CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Searching for location:\nLatitude: \(latitude)\nLongitude: \(longitude)")
        
        GTStreamableManager.searchForLocation(latitude, longitude: longitude, radius: AppConfig.sharedInstance.locationRadius, successBlock: { (response) -> Void in
            let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
            
            self.processAnnotations(listItemsResult.items!)
            self.finalizeLoad()
        }) { (response) -> Void in
            self.finalizeLoad()
            
            DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, reason: response.error.reason)
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
        
        if !initialMapSetup {
            initialMapSetup = true
            
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(location.coordinate, AppConfig.sharedInstance.mapInitialSpanDistance, AppConfig.sharedInstance.mapInitialSpanDistance), animated: true)
        }
        else {
            mapView.camera.centerCoordinate = location.coordinate
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.calculateSpanDistance() > AppConfig.sharedInstance.mapMaxSpanDistance && !modifyingMap { // Enforce maximum zoom level.
            modifyingMap = true // Prevents strange infinite loop case.
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapView.region.center, AppConfig.sharedInstance.mapMaxSpanDistance, AppConfig.sharedInstance.mapMaxSpanDistance), animated: true)
            modifyingMap = false
        }
        
        doClusterAnnotations()
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if toShowLatitude == nil && toShowLongitude == nil { // We are not showing a custom location.
            zoomMapToLocation(userLocation.location!) // So center map to user's location initially.
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            let reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if clusterView == nil {
                let options = FBAnnotationClusterViewOptions(smallClusterImage: "clusterSmall", mediumClusterImage: "clusterMedium", largeClusterImage: "clusterLarge")
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: options)
            }
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
            print(annotation.title)
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
    
    // MARK: - Timer
    
    func stopTimer() {
        if refreshTimer != nil {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }
    
    func startTimer() {
        stopTimer()
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(AppConfig.sharedInstance.mapRefreshRate, target: self, selector: #selector(self.loadItems), userInfo: nil, repeats: true)
        loadItems()
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        let items = [backBtn, bottomButtonsContainer]
        
        for view in items {
            view.applyMaterializeStyle(0.2)
        }
        
        backBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        gridBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        locateBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
    }
    
    func setupMapView() {
        mapView.rotateEnabled = true
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.showsBuildings = true
        mapView.showsTraffic = false
        mapView.showsCompass = false
        mapView.showsUserLocation = (CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse)
    }
}
