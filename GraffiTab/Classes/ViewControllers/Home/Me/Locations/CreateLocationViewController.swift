//
//  CreateLocationViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 23/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import MapKit
import GraffiTab_iOS_SDK
import AddressBookUI
import CocoaLumberjack

class CreateLocationViewController: BackButtonViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var backBtn: TintButton!
    @IBOutlet weak var searchBtn: TintButton!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var toEdit: GTLocation?
    
    var lastPlacemark: CLPlacemark?
    var isMovedByTap = false
    var isSearching = false
    var showedFirstUserLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupButtons()
        setupMapView()
        
        if toEdit != nil {
            centerToLocation(CLLocation(latitude: toEdit!.latitude!, longitude: toEdit!.longitude!))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController != nil && !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickCreate(sender: AnyObject) {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Attempting to create location")
        
        if lastPlacemark == nil {
            DialogBuilder.showErrorAlert("Select a location first.", title: App.Title)
        }
        else {
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            let success = {
                self.view.hideActivityView()
                
                DialogBuilder.showSuccessAlert("Location saved successfully!", title: App.Title, okAction: {
                    Utils.runWithDelay(0.3, block: {
                        self.onClickBack(nil)
                    })
                })
            }
            let failure = {(response: GTResponseObject) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
            }
            
            if toEdit != nil {
                GTMeManager.editLocation(toEdit!.id!, address: searchField.text!, latitude: lastPlacemark!.location!.coordinate.latitude, longitude: lastPlacemark!.location!.coordinate.longitude, successBlock: { (response) in
                    success()
                    }, failureBlock: { (response) in
                        failure(response)
                })
            }
            else {
                GTMeManager.createLocation(searchField.text!, latitude: lastPlacemark!.location!.coordinate.latitude, longitude: lastPlacemark!.location!.coordinate.longitude, successBlock: { (response) in
                    success()
                }, failureBlock: { (response) in
                    failure(response)
                })
            }
        }
    }
    
    @IBAction func onClickBack(sender: AnyObject?) {
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
    
    @IBAction func onClickSearch(sender: AnyObject) {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Attempting to search for location")
        
        isSearching = !isSearching
        
        let searchWidth: CGFloat
        if isSearching {
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
    
    func showLoadingIndicator() {
        searchBtn.tintColor = UIColor(hexString: "#efefef")
        if !loadingIndicator!.isAnimating() {
            loadingIndicator.startAnimating()
        }
    }
    
    func hideLoadingIndicator() {
        searchBtn.tintColor = UIColor(hexString: Colors.Main)
        loadingIndicator.stopAnimating()
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
        if !showedFirstUserLocation {
            if toEdit == nil {
                centerToLocation(userLocation.location!)
            }
        }
        
        showedFirstUserLocation = true
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        showLoadingIndicator()
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)) { (placemarks, error) in
            self.hideLoadingIndicator()
            
            if error != nil {
                DDLogError("[\(NSStringFromClass(self.dynamicType))] Geocoder failed with error - \(error)")
                return
            }
            
            if placemarks != nil && placemarks?.count > 0 {
                self.lastPlacemark = placemarks?.first
                
                let addressText = ABCreateStringWithAddressDictionary(self.lastPlacemark!.addressDictionary!, false)
                let newString = addressText.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).joinWithSeparator(", ")
                self.searchField.text = newString
            }
        }
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    func setupButtons() {
        let items = [backBtn, searchContainer]
        
        for view in items {
            Utils.applyShadowEffectToView(view)
            view.layer.cornerRadius = 5.0
        }
    }
    
    func setupMapView() {
        mapView.rotateEnabled = false
    }
}
