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
import kingpin
import MZFormSheetPresentationController
import JTMaterialTransition
import CocoaLumberjack
import AddressBookUI

class ExploreViewController: BackButtonViewController, MKMapViewDelegate, KPClusteringControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backBtn: TintButton!
    @IBOutlet weak var gridBtn: TintButton!
    @IBOutlet weak var locateBtn: TintButton!
    @IBOutlet weak var addLocationBtn: TintButton!
    @IBOutlet weak var bottomButtonsContainer: UIView!
    
    var toShowLatitude: CLLocationDegrees?
    var toShowLongitude: CLLocationDegrees?
    
    var lastPlacemark: CLPlacemark?
    var lastPlacemarkAddress: String?
    var items = [GTStreamable]()
    var annotations = [StreamableAnnotation]()
    var refreshTimer: NSTimer?
    var clusteringController: KPClusteringController?
    var initialMapCenter = false
    var initialMapRegionChanged = false
    var modifyingMap = false
    var prevAnnotationCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        setupMapView()
        setupClustering()
        
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
    
    @IBAction func onClickAddLocation(sender: AnyObject) {
        DialogBuilder.showYesNoAlert(self, status: NSLocalizedString("controller_create_location_create_prompt", comment: ""), title: App.Title, yesTitle: NSLocalizedString("other_save", comment: ""), noTitle: NSLocalizedString("other_cancel", comment: ""), yesAction: {
            self.saveLocation()
        }) { 
            
        }
    }
    
    @IBAction func onClickLocate(sender: AnyObject) {
        if mapView.userLocation.location != nil {
            mapView.camera.centerCoordinate = mapView.userLocation.coordinate
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
        let annotation = (sender.view as! StreamableAnnotationView).getStreamableAnnotation()
        let streamableAnnotation = annotation

        ViewControllerUtils.showStreamableDetails(streamableAnnotation.streamable!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
    }
    
    func saveLocation() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to create location")
        
        if lastPlacemark == nil {
            DialogBuilder.showErrorAlert(self, status: NSLocalizedString("controller_create_location_not_selected", comment: ""), title: App.Title)
        }
        else {
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("location_create", label: nil)
            
            self.view.showActivityView()
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.createLocation(lastPlacemarkAddress!, latitude: lastPlacemark!.location!.coordinate.latitude, longitude: lastPlacemark!.location!.coordinate.longitude, successBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_create_location_saved", comment: ""), title: NSLocalizedString("other_success", comment: ""))
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }
    }
    
    // MARK: - Loading
    
    func loadItems() {
        if mapView == nil {
            return
        }
        
        let mapCenter = mapView.centerCoordinate
        let location = CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        
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
        if annotations.count != prevAnnotationCount {
            clusteringController!.setAnnotations(annotations)
        }
        prevAnnotationCount = annotations.count
        
        clusteringController!.refresh(true)
    }
    
    // MARK: - MKMapViewDelegate
    
    func zoomMapToLocation(location: CLLocation) {
        if mapView == nil {
            return
        }
        
        if !initialMapCenter {
            initialMapCenter = true
            
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(location.coordinate, AppConfig.sharedInstance.mapInitialSpanDistance, AppConfig.sharedInstance.mapInitialSpanDistance), animated: true)
        }
        else {
            mapView.camera.centerCoordinate = location.coordinate
        }
    }
    
    func reverseGeocodeMapCenter() {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)) { (placemarks, error) in
            if error != nil {
                DDLogError("[\(NSStringFromClass(self.dynamicType))] Geocoder failed with error - \(error)")
                return
            }
            
            if placemarks != nil && placemarks?.count > 0 {
                self.lastPlacemark = placemarks?.first
                
                let addressText = ABCreateStringWithAddressDictionary(self.lastPlacemark!.addressDictionary!, false)
                let newString = addressText.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).joinWithSeparator(", ")
                self.lastPlacemarkAddress = newString
            }
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if initialMapRegionChanged && mapView.calculateSpanDistance() > AppConfig.sharedInstance.mapMaxSpanDistance && !modifyingMap { // Enforce maximum zoom level.
            modifyingMap = true // Prevents strange infinite loop case.
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapView.region.center, AppConfig.sharedInstance.mapMaxSpanDistance, AppConfig.sharedInstance.mapMaxSpanDistance), animated: true)
            modifyingMap = false
        }
        
        clusteringController!.refresh(true)
        
        reverseGeocodeMapCenter()
        
        initialMapRegionChanged = true
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
        
        if annotation is KPAnnotation {
            let a = annotation as! KPAnnotation
            
            if a.isCluster() {
                let reuseId = "Cluster"
                var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? ClusterAnnotationView
                
                if (clusterView == nil) {
                    let options = ClusterAnnotationViewOptions(smallClusterImage: "clusterSmall", mediumClusterImage: "clusterMedium", largeClusterImage: "clusterLarge")
                    clusterView = ClusterAnnotationView(annotation: annotation, reuseIdentifier: reuseId, options: options)
                }
                clusterView?.annotation = a
                clusterView?.recomputeCluster()
                
                return clusterView
            }
            else {
                let reuseId = "Streamable"
                var streamableView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? StreamableAnnotationView
                
                if streamableView == nil {
                    streamableView = StreamableAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                }
                streamableView?.annotation = a
                (annotation as! KPAnnotation).title = streamableView!.getStreamableAnnotation().streamable!.user!.getFullName()
                
                return streamableView
            }
        }
        
        return nil
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if view is ClusterAnnotationView { // Select cluster.
            // Process cluster click.
            let annotation = view.annotation as! KPAnnotation
            
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
        else if view is StreamableAnnotationView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openAnnotationView(_:)))
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if view is StreamableAnnotationView {
            view.gestureRecognizers?.forEach({ (recognizer) in
                view.removeGestureRecognizer(recognizer)
            })
        }
    }
    
    // MARK: - KPClusteringControllerDelegate
    
    func clusteringControllerShouldClusterAnnotations(clusteringController: KPClusteringController!) -> Bool {
        return true
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
        addLocationBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
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
    
    func setupClustering() {
        let algorithm = KPGridClusteringAlgorithm()
        algorithm.annotationSize = CGSizeMake(25, 50)
        algorithm.clusteringStrategy = KPGridClusteringAlgorithmStrategy.TwoPhase
        
        clusteringController = KPClusteringController(mapView: mapView, clusteringAlgorithm: algorithm)
        clusteringController!.delegate = self
    }
}
