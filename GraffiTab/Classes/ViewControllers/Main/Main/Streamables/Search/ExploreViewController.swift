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

class ExploreViewController: BackButtonViewController, UITextFieldDelegate, MKMapViewDelegate, FBClusteringManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var backBtn: TintButton!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchWidthConstraint: NSLayoutConstraint!
    
    var isSearching: Bool?
    var showedFirstUserLocation: Bool?
    var items: [GTStreamable]?
    var annotations: [FBAnnotation]?
    let clusteringManager = FBClusteringManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        items = [GTStreamable]()
        annotations = [FBAnnotation]()
        isSearching = false
        showedFirstUserLocation = false
        
        setupButtons()
        setupMapView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onClickGrid(sender: AnyObject) {
        
    }
    
    @IBAction func onClickLocation(sender: AnyObject) {
        centerToLocation(mapView.userLocation.location!)
    }
    
    @IBAction func onClickSearch(sender: AnyObject) {
        isSearching = !isSearching!
        
        let searchWidth: CGFloat
        if isSearching! {
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
                if self.isSearching! {
                    self.searchField.becomeFirstResponder()
                }
                else {
                    self.view.endEditing(true)
                }
            }
        }
    }
    
    // MARK: - Loading
    
    func loadItems() {
        // First we need to calculate the corners of the map so we get the points.
        let nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
        let swPoint = CGPointMake(mapView.bounds.origin.x, mapView.bounds.origin.y + mapView.bounds.size.height);
        
        // Then transform those point into lat, lng values.
        let neCoord = mapView.convertPoint(nePoint, toCoordinateFromView: mapView)
        let swCoord = mapView.convertPoint(swPoint, toCoordinateFromView: mapView)
        print("DEBUG: Map bounding rectangle is \(neCoord), + \(swCoord)")
        
        GTStreamableManager.searchForLocation(neCoord.latitude, neLongitude: neCoord.longitude, swLatitude: swCoord.latitude, swLongitude: swCoord.longitude, successBlock: { (response) -> Void in
            let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
            
            self.processAnnotations(listItemsResult.items!)
            self.finalizeLoad()
        }) { (response) -> Void in
            self.finalizeLoad()
            
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
        }
    }
    
    func processAnnotations(streamables: [GTStreamable]) {
        for streamable in streamables {
            if items?.contains({
                $0.id == streamable.id
            }) == false {
                let annotation = FBAnnotation()
                annotation.title = "Graffiti"
                annotation.coordinate = CLLocationCoordinate2D(latitude: streamable.latitude!, longitude: streamable.longitude!)
                
                items?.append(streamable)
                annotations?.append(annotation)
            }
        }
    }
    
    func finalizeLoad() {
        clusteringManager.setAnnotations(annotations!)
        
        // Cluster annotations.
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth: Double = self.mapView.visibleMapRect.size.width
            let scale: Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
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
                DialogBuilder.showOKAlert("No locations found for this address.", title: App.Title)
            }
            
            if placemarks?.count > 1 { // More than 1 address matches found. Ask user which one to use.
                DialogBuilder.showOKAlert("Multiple matches found. The first one will be used.", title: App.Title, okAction: { 
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
        var region = MKCoordinateRegion()
        region.center = location.coordinate
        region.span.latitudeDelta = 0.2
        region.span.longitudeDelta = 0.2
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !showedFirstUserLocation! {
            centerToLocation(userLocation.location!)
        }
        
        showedFirstUserLocation = true
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.region.span.latitudeDelta > 11.0 || mapView.region.span.longitudeDelta > 11.0 {
            var region = mapView.region
            region.span = MKCoordinateSpanMake(10.0, 10.0)
            mapView.setRegion(region, animated: true)
        }
        else {
            loadItems()
        }
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
        else {
            reuseId = "Pin"
//            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as! MKPinAnnotationView
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.pinTintColor = UIColor.greenColor()
            return pinView
        }
    }
    
    // MARK: - FBClusteringManagerDelegate
    
    func cellSizeFactorForCoordinator(coordinator: FBClusteringManager) -> CGFloat {
        return 1.0
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    func setupButtons() {
        let items = [backBtn, bottomContainer, searchContainer]
        
        for view in items {
            view.layer.cornerRadius = 5.0
            view.layer.masksToBounds = false
            view.layer.shadowRadius = 3.0
            view.layer.shadowColor = UIColor.blackColor().CGColor;
            view.layer.shadowOffset = CGSizeMake(1.6, 1.6)
            view.layer.shadowOpacity = 0.5
        }
    }
    
    func setupMapView() {
        mapView.rotateEnabled = false
    }
}
