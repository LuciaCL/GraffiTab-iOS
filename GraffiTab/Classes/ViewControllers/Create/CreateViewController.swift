//
//  CreateViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import imglyKit
import GraffiTab_iOS_SDK
import CocoaLumberjack
import MZFormSheetPresentationController
import PAGestureAssistant

enum DrawingAssistantState {
    case Intro
    case DrawLine
    case DrawColorLine
    case DrawStrokeLine
    case DrawToolLine
    case Color
    case Stroke
    case Menu
    case Tool
    case Eraser
    case Background
    case Enhancer
    case Publish
}

class CreateViewController: CCViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, ColorSprayCanCellDelegate, PublishDelegate, CanvasDelegate, ToolStackControllerDelegate {

    @IBOutlet weak var toolCollectionView: UICollectionView!
    @IBOutlet weak var canvasContainerXconstraint: NSLayoutConstraint!
    @IBOutlet weak var colorsTrailingconstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasXconstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasYconstraint: NSLayoutConstraint!
    @IBOutlet weak var colorsTableView: UITableView!
    @IBOutlet weak var drawingContainer: UIView!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var phraseTextLbl: UILabel!
    @IBOutlet weak var phraseAuthorLbl: UILabel!
    @IBOutlet weak var phraseContainer: UIView!
    @IBOutlet weak var undoBtn: DrawingOptionButton!
    @IBOutlet weak var redoBtn: DrawingOptionButton!
    @IBOutlet weak var backgroundBtn: DrawingOptionButton!
    @IBOutlet weak var enhanceBtn: DrawingOptionButton!
    @IBOutlet weak var publishBtn: TintButton!
    @IBOutlet weak var onCanvasTuneBtn: MaterializeRoundButton!
    @IBOutlet weak var onCanvasColorBtn: MaterializeRoundButton!
    @IBOutlet weak var onCanvasMenuBtn: MaterializeRoundButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    // Edit.
    var toEdit: GTStreamable?
    var toEditImage: UIImage?
  
    // Generic.
    var canvasScene: IntroScene?
    var canvas: LineDrawer?
    var colors: [UIColor]?
    var chunkedColors: [[UIColor]]?
    var tools: [String]?
    var laidOut: Bool = false
    var selectedToolIndex: Int = 6
    var isPortrait: Bool?
    var menuPinchStartPointX: CGFloat?
    var isMenuOpen: Bool?
    var isColorsOpen: Bool?
    var minRows: Int = 0
    
    // Drawing assistant.
    var drawingAssistantIndex = 0
    var drawingAssistantSequence: [DrawingAssistantState] = [.Intro, .DrawLine, .Color, .DrawColorLine, .Stroke, .DrawStrokeLine, .Menu, .Tool, .DrawToolLine, .Eraser, .Background, .Enhancer, .Publish]
    var isDrawAssistantMode = false
    var interactiveComponents: [UIView]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        isPortrait = self.view.frame.width < self.view.frame.height
        isMenuOpen = false
        isColorsOpen = false
        interactiveComponents = [CCDirector.sharedDirector().view,
                                               onCanvasTuneBtn,
                                               onCanvasColorBtn,
                                               onCanvasMenuBtn,
                                               colorBtn,
                                               toolCollectionView,
                                               backgroundBtn,
                                               enhanceBtn,
                                               publishBtn,
                                               undoBtn,
                                               redoBtn]
        
        setupCocos2D()
        
        loadColors()
        loadTools()
        loadPhrase()
        
        setupColorConstants()
        
        configureUndoButtons()
        
        if toEdit != nil {
            Utils.runWithDelay(0.3, block: {
                self.loadEdit()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if laidOut == false {
            laidOut = true
            
            setupColorConstants()
            colorsTableView.reloadData()
            
            configureToolsLayout()
            
            Utils.runWithDelay(1.3, block: { () in
                self.checkScreenAssistant()
            })
        }
    }
    
    @IBAction func onClickSkip(sender: AnyObject) {
        Settings.sharedInstance.showedDrawingAssistant = true
        isDrawAssistantMode = false
        configureUIComponentsForTutorial(nil, showAll: true)
        hideSkipBtn()
        self.stopGestureAssistant()
        
        DialogBuilder.showOKAlert("Ready to draw? No problem, you can enable the tutorial again from Settings.", title: App.Title)
    }
    
    @IBAction func onClickPublish(sender: AnyObject?) {
//        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Showing publish screen")
//        
//        let sampleImage = self.canvas?.grabFrame()
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PublishViewController") as! PublishViewController
//        vc.streamableImage = sampleImage
//        vc.toEdit = toEdit
//        vc.delegate = self
//        self.presentViewController(vc, animated: true, completion: nil)
        
        let handler = {
            // TODO: Uncomment this to show the AR publisher. For now we won't track the position of the image in the real world.
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to publish")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("attempting_to_publish", label: nil)
            
            let sampleImage = self.canvas?.grabFrame()
            var pitch = GTDeviceMotionManager.manager.pitch
            var roll = GTDeviceMotionManager.manager.roll
            var yaw = GTDeviceMotionManager.manager.yaw
            var latitude: CLLocationDegrees = 0
            var longitude: CLLocationDegrees = 0
            let location = GTLocationManager.manager.lastLocation
            
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
                
                DialogBuilder.showYesNoSuccessAlert("Your post has been published! Would you like to continue drawing?", title: App.Title, yesTitle: "Continue", noTitle: "Close Canvas", yesAction: {
                    
                    }, noAction: {
                        self.didPublish()
                })
            }
            let failBlock = { (response: GTResponseObject) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            }
            
            let saveBlock = {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                if self.toEdit != nil {
                    GTMeManager.editGraffiti(self.toEdit!.id!, image: sampleImage!, latitude: latitude, longitude: longitude, pitch: pitch!, roll: roll!, yaw: yaw!, successBlock: { (response) -> Void in
                        successBlock()
                    }) { (response) -> Void in
                        failBlock(response)
                    }
                }
                else {
                    GTMeManager.createGraffiti(sampleImage!, latitude: latitude, longitude: longitude, pitch: pitch!, roll: roll!, yaw: yaw!, successBlock: { (response) -> Void in
                        successBlock()
                    }) { (response) -> Void in
                        failBlock(response)
                    }
                }
            }
            
            if location == nil {
                DialogBuilder.showYesNoAlert("Your location could not be determined right now. Would you like to still publish this post?", title: App.Title, yesAction: {
                    // Register analytics events.
                    AnalyticsUtils.sendAppEvent("attempting_to_publish_without_location", label: nil)
                    
                    saveBlock()
                    }, noAction: {
                        // Register analytics events.
                        AnalyticsUtils.sendAppEvent("publish_refused_no_location", label: nil)
                })
            }
            else {
                latitude = location!.coordinate.latitude
                longitude = location!.coordinate.longitude
                
                saveBlock()
            }
        }
        
        GTPermissionsManager.manager.checkPermission(.LocationWhenInUse, controller: self, accessGrantedHandler: {
            handler()
        }) {
            handler()
        }
    }
    
    @IBAction func onClickShare(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing share dialog")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("share", label: "Sharing from Creator")
        
        let sampleImage = self.canvas?.grabFrame()
        Utils.shareImage(sampleImage!, viewController: self)
    }
    
    @IBAction func onClickSave(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Saving canvas snapshot")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("saving", label: "Saving canvas snapshot")
        
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        let sampleImage = self.canvas?.grabFrame()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            UIImageWriteToSavedPhotosAlbum(sampleImage!, nil, nil, nil);
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Shapshot saved")
                
                self.view.hideActivityView()
                
                Utils.runWithDelay(0.3, block: {
                    DialogBuilder.showSuccessAlert("Your graffiti was saved in your photos album", title: App.Title)
                })
            })
        })
    }
    
    @IBAction func onClickDone(sender: AnyObject) {
        if isDrawAssistantMode {
            // Finish tutorial.
            self.isDrawAssistantMode = false
            self.stopGestureAssistant()
            hideSkipBtn()
            
            Settings.sharedInstance.showedDrawingAssistant = true
        }
        
        configureUIComponentsForTutorial(nil, showAll: true)
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing publish options")
        let actionSheet = buildActionSheet("Looks great! How about sharing it with the rest of the world?")
        actionSheet.addButtonWithTitle("Publish", image: UIImage(named: "ic_done_white"), type: .Default) { (sheet) in
            self.hideMenu({
                self.onClickPublish(nil)
            })
        }
        actionSheet.addButtonWithTitle("Share", image: UIImage(named: "ic_share_white"), type: .Default) { (sheet) in
            self.onClickShare(nil)
        }
        actionSheet.addButtonWithTitle("Save to Photos Album", image: UIImage(named: "ic_file_download_white"), type: .Default) { (sheet) in
            self.onClickSave(nil)
        }
        actionSheet.addButtonWithTitle("Discard", image: UIImage(named: "ic_clear_white"), type: .Destructive) { (sheet) in
            DialogBuilder.showYesNoAlert("Are you sure you want to discard this drawing? Any unsaved progress will be lost.", title: App.Title, yesTitle: "Yes, discard it!", noTitle: "Cancel", yesAction: {
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("discard", label: nil)
                
                self.onClickClose(nil)
            }, noAction: {
                    
            })
        }
        actionSheet.show()
    }
    
    @IBAction func onClickEnhance(sender: AnyObject?) {
        if isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.stopGestureAssistant()
        }
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing enhancer tool")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("enhance_drawing", label: nil)
        
        // Downsample image to allow quick processing.
        let sampleImage = self.canvas?.grabFrame()
        let optimizedImage = UIImage(data: UIImageJPEGRepresentation(sampleImage!, 0.6)!)
        
        let configuration = Configuration() { builder in
            builder.configurePhotoEditorViewController({ (options) in
                options.allowedPhotoEditorActions = [.Filter, .Adjust, .Separator, .Text, .Sticker, .Separator, .Focus, .Magic]
            })
        }
        
        let photoEditViewController = PhotoEditViewController(photo: optimizedImage!, configuration: configuration)
        let toolStackController = ToolStackController(photoEditViewController: photoEditViewController, configuration: configuration)
        toolStackController.delegate = self
        
        let nav = UINavigationController(rootViewController: toolStackController)
        nav.navigationBar.barTintColor = UIColor(hexString: "#222222")
        nav.navigationBar.translucent = false
        presentViewController(nav, animated: true, completion: nil)
    }
    
    @IBAction func onClickClose(sender: AnyObject?) {
        super.close(sender)
    }
    
    @IBAction func onClickChangeBackground(sender: AnyObject) {
        if isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.stopGestureAssistant()
        }
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to change background")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("change_background", label: nil)
        
        GTPermissionsManager.manager.checkPermission(.Photos, controller: self, accessGrantedHandler: { 
            self.askForImage()
        })
    }
    
    @IBAction func onLongClickCollectionView(sender: AnyObject) {
        let recognizer = sender as! UIGestureRecognizer
        
        if recognizer.state == .Began {
            let p = recognizer.locationInView(toolCollectionView)
            let indexPath = toolCollectionView.indexPathForItemAtPoint(p)
            if indexPath != nil {
                if indexPath?.row == 0 {
                    let actionSheet = buildActionSheet("What would you like to do?")
                    actionSheet.addButtonWithTitle("Clear drawing layer", type: .Default) { (sheet) in
                        DialogBuilder.showYesNoAlert("Are you sure you want to clear your drawing? Any unsaved progress will be lost.", title: App.Title, yesTitle: "Yes, clear it!", noTitle: "Cancel", yesAction: {
                            self.canvas!.clearDrawingLayer()
                        }, noAction: {
                                
                        })
                    }
                    actionSheet.addButtonWithTitle("Clear background layer", type: .Default) { (sheet) in
                        DialogBuilder.showYesNoAlert("Are you sure you want to clear the background image? Any unsaved progress will be lost.", title: App.Title, yesTitle: "Yes, clear it!", noTitle: "Cancel", yesAction: {
                            self.canvas!.clearBackground()
                        }, noAction: {
                                
                        })
                    }
                    actionSheet.addButtonWithTitle("Clear everything", image: UIImage(named: "ic_clear_white"), type: .Destructive) { (sheet) in
                        DialogBuilder.showYesNoAlert("Are you sure you want to clear your drawing? Any unsaved progress will be lost.", title: App.Title, yesTitle: "Yes, clear it!", noTitle: "Cancel", yesAction: {
                            self.canvas!.clearCanvas()
                        }, noAction: {
                                
                        })
                    }
                    actionSheet.show()
                }
            }
        }
    }
    
    @IBAction func onClickUndo(sender: AnyObject) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Undo action")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("undo", label: nil)
        
        canvas!.undo()
        
        configureUndoButtons()
    }
    
    @IBAction func onClickRedo(sender: AnyObject) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Redo action")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("redo", label: nil)
        
        canvas!.redo()
        
        configureUndoButtons()
    }
    
    @IBAction func onClickMenu(recognizer: AnyObject?) {
        if isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.stopGestureAssistant()
        }
        
        if isColorsOpen! {
            hideColors({ 
                self.showMenu()
            })
        }
        else if !isMenuOpen! {
            showMenu()
        }
        else if isMenuOpen! {
            hideMenu(nil)
        }
    }
    
    @IBAction func onClickColors(sender: AnyObject?) {
        if isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.stopGestureAssistant()
        }
        
        if isMenuOpen! {
            hideMenu({
                self.showColors()
            })
        }
        else if !isColorsOpen! {
            showColors()
        }
        else if isColorsOpen! {
            hideColors(nil)
        }
    }
    
    @IBAction func onClickTune(sender: AnyObject) {
        if isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.stopGestureAssistant()
        }
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing tool options")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("tool_options", label: nil)
        
        MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
        MZFormSheetPresentationController.appearance().shouldCenterHorizontally = true
        MZFormSheetPresentationController.appearance().shouldCenterVertically = true
        MZFormSheetPresentationController.appearance().shouldDismissOnBackgroundViewTap = true
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TuneViewController") as! TuneViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: vc)
        formSheetController.presentationController?.contentViewSize = CGSizeMake(300, 220)
        formSheetController.contentViewControllerTransitionStyle = .SlideFromBottom
        formSheetController.allowDismissByPanningPresentedView = true
        formSheetController.didDismissContentViewControllerHandler = {vc in
            if self.isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
                self.showNextDrawingAssistantScreen()
            }
        }
        
        vc.sizeSlider.minimumValue = Float(MIN_SIZE_OFFSET)
        vc.sizeSlider.maximumValue = Float(MAX_SIZE_OFFSET)
        vc.sizeSlider.value = Float(canvas!.sizeOffset)
        
        vc.opacitySlider.minimumValue = Float(MIN_OPACITY_OFFSET)
        vc.opacitySlider.maximumValue = Float(MAX_OPACITY_OFFSET)
        vc.opacitySlider.value = Float(canvas!.opacityOffset)
        
        vc.sizeChangedBlock = { (value) in
            self.canvas!.sizeOffset = CGFloat(value)
        }
        vc.opacityChangedBlock = { (value) in
            self.canvas!.opacityOffset = CGFloat(value)
        }
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func configureUndoButtons() {
        if canvas!.canUndo() {
            undoBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            undoBtn.tintColor = UIColor(hexString: "BBBBBB")
        }
        else {
            undoBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            undoBtn.tintColor = UIColor(hexString: "BBBBBB")?.colorWithAlphaComponent(0.2)
        }
        if canvas!.canRedo() {
            redoBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            redoBtn.tintColor = UIColor(hexString: "BBBBBB")
        }
        else {
            redoBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            redoBtn.tintColor = UIColor(hexString: "BBBBBB")?.colorWithAlphaComponent(0.2)
        }
    }
    
    // MARK: - Drawing assistant
    
    func checkScreenAssistant() {
        if !Settings.sharedInstance.showedDrawingAssistant! {
            DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Showing drawing assistant")
            AnalyticsUtils.sendAppEvent("showing_drawing_assistant", label: nil)
            
            isDrawAssistantMode = true
            drawingAssistantIndex = 0;
            showNextDrawingAssistantScreen()
            showSkipBtn()
        }
    }
    
    func showNextDrawingAssistantScreen() {
        if drawingAssistantIndex >= drawingAssistantSequence.count {
            return
        }
        
        let state = drawingAssistantSequence[drawingAssistantIndex]
        
        switch state {
            case .Intro:
                configureUIComponentsForTutorial(CCDirector.sharedDirector().view, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.view, text: "Drawing with the canvas is quick and easy and we'll show you how to do it. Tap on the screen to get started!", afterIdleInterval: 0, completion: {finished in
                    self.showNextDrawingAssistantScreen()
                })
                break
            case .DrawLine, .DrawToolLine, .DrawStrokeLine, .DrawColorLine:
                configureUIComponentsForTutorial(CCDirector.sharedDirector().view, showAll: false)
                
                var text: String = ""
                if state == .DrawLine {
                    text = "You can draw by sliding your finger on the screen. Give it a try!"
                }
                else if state == .DrawToolLine {
                    text = "Great tool choice. Lets see it in action!"
                }
                else if state == .DrawStrokeLine {
                    text = "Give that new brush a try!"
                }
                else if state == .DrawColorLine {
                    text = "That color looks nice. Why don't you give it a try?"
                }
                self.showGestureAssistantForSwipeDirection(PAGestureAssistantSwipeDirectonDown, text: text, afterIdleInterval: 0.5)
                break
            case .Color:
                configureUIComponentsForTutorial(onCanvasColorBtn, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.onCanvasColorBtn, text: "Drawing lines is fun but it's even nicer with colors. Tap on the palette to choose a different color.", afterIdleInterval: 0.3)
                break
            case .Stroke:
                configureUIComponentsForTutorial(onCanvasTuneBtn, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.onCanvasTuneBtn, text: "In addition to colors you can also control the width and opacity of the current brush. Tap the brush settings to check it out.", afterIdleInterval: 0.3)
                break
            case .Menu:
                configureUIComponentsForTutorial(onCanvasMenuBtn, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.onCanvasMenuBtn, text: "So far so good but what's a great artist without his brushes? Let's see what you've got in your toolbox.", afterIdleInterval: 0.3)
                break
            case .Tool:
                configureUIComponentsForTutorial(toolCollectionView, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.toolCollectionView, text: "These are your available tools. Tap on a different tool to continue.", afterIdleInterval: 0.3)
                break
            case .Eraser:
                configureUIComponentsForTutorial(toolCollectionView, showAll: false)
                
                let cell = self.toolCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                if cell != nil {
                    self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: cell!, text: "Even great artists make mistakes sometimes. Do not fear, we have the perfect tool for this. Tap the eraser to erase mistakes.", afterIdleInterval: 0.3)
                }
                break
            case .Background:
                configureUIComponentsForTutorial(backgroundBtn, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.backgroundBtn, text: "The white canvas is nice but can quickly become boring. Why not put a background picture and draw on top of it?", afterIdleInterval: 0)
                break
            case .Enhancer:
                configureUIComponentsForTutorial(enhanceBtn, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.enhanceBtn, text: "Now that your masterpiece is almost done, it's time to add some cool effects to it and make it looks really pro. Tap the enhancer to add filters or stickers to your drawing.", afterIdleInterval: 0.3)
                break
            case .Publish:
                configureUIComponentsForTutorial(publishBtn, showAll: false)
                
                self.showGestureAssistantForTap(PAGestureAssistantTapSingle, view: self.publishBtn, text: "Not bad for a first try! Why don't you share it with your friends or the rest of the GraffiTab community?", afterIdleInterval: 0)
                break
        }
        
        drawingAssistantIndex += 1
    }
    
    func configureUIComponentsForTutorial(excludedView: UIView?, showAll: Bool) {
        UIView.animateWithDuration(0.3, animations: {
            for view in self.interactiveComponents! {
                if showAll {
                    view.userInteractionEnabled = true
                    view.alpha = 1.0
                }
                else {
                    if view != excludedView {
                        view.userInteractionEnabled = false
                        view.alpha = 0.3
                    }
                    else {
                        view.userInteractionEnabled = true
                        view.alpha = 1.0
                    }
                }
            }
        }, completion: nil)
    }
    
    func hideSkipBtn() {
        UIView.animateWithDuration(0.3, animations: {
            self.skipBtn.alpha = 0.0
        }, completion: nil)
    }
    
    func showSkipBtn() {
        UIView.animateWithDuration(0.3, animations: {
            self.skipBtn.alpha = 1.0
        }, completion: nil)
    }
    
    // MARK: - Menus
    
    func showMenu() {
        isMenuOpen = true
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasXconstraint.constant = 55
            self.canvasYconstraint.constant = 55
            self.canvasView.superview!.setNeedsUpdateConstraints()
            self.canvasView.superview!.layoutIfNeeded()
            }, completion: nil)
        
        if self.isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.showNextDrawingAssistantScreen()
        }
    }
    
    func hideMenu(completionBlock: (() -> ())?) {
        isMenuOpen = false
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasXconstraint.constant = 0
            self.canvasYconstraint.constant = 0
            self.canvasView.superview!.setNeedsUpdateConstraints()
            self.canvasView.superview!.layoutIfNeeded()
        }, completion: {(finished) in
            if finished && completionBlock != nil {
                completionBlock!()
            }
        })
    }
    
    func showColors() {
        self.isColorsOpen = true
        colorsTableView.reloadData()
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasContainerXconstraint.constant = -self.colorsTableView.frame.width
            self.colorsTrailingconstraint.constant = 0
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideColors(completionBlock: (() -> ())?) {
        self.isColorsOpen = false
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasContainerXconstraint.constant = 0
            self.colorsTrailingconstraint.constant = -self.colorsTableView.frame.width
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }, completion: {(finished) in
            if finished && completionBlock != nil {
                completionBlock!()
            }
        })
    }
    
    // MARK: - Images
    
    override func didChooseImage(image: UIImage?) {
        canvas!.setBackground(image)
        
        if self.isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.showNextDrawingAssistantScreen()
        }
    }
    
    override func cropAspectRatio() -> CGSize {
        let view = self.canvasView != nil ? self.canvasView : self.view;
        let offset = view.frame.height > view.frame.width ? 25 : -45
        return CGSizeMake(view.frame.size.width + CGFloat(offset), view.frame.size.width / (view.frame.size.width / view.frame.size.height))
    }
    
    override func resizingEnabled() -> Bool {
        return false
    }
    
    override func rotationEnabled() -> Bool {
        return false
    }
    
    override func resetEnabled() -> Bool {
        return false
    }
    
    // MARK: - Loading
    
    func loadPhrase() {
        var phrases = [[String : String]]()
        phrases.append(["author":"Salvador Dali", "text":"Drawing is the honesty of the art. There is no possibility of cheating. It is either good or bad."])
        phrases.append(["author":"Paul Klee", "text":"A drawing is simply a line going for a walk."])
        phrases.append(["author":"Henri Cartier-Bresson", "text":"Photography is an immediate reaction, drawing is a meditation."])
        phrases.append(["author":"John W. Gardner", "text":"Life is the art of drawing without an eraser."])
        phrases.append(["author":"David Hockney", "text":"Drawing is rather like playing chess: your mind races ahead of the moves that you eventually make."])
        phrases.append(["author":"John Ruskin", "text":"All art is but dirtying the paper delicately."])
        phrases.append(["author":"Criss Jami", "text":"Create with the heart; build with the mind."])
        phrases.append(["author":"Vincent van Gogh", "text":"I sometimes think there is nothing so delightful as drawing."])
        phrases.append(["author":"Jean-Auguste-Dominique Ingres", "text":"Faites des lignes. Faites beaucoup de lignes."])
        phrases.append(["author":"Edgar Degas", "text":"Drawing is not what one sees but what one can make others see."])
        
        let phraseDict = phrases[random() % phrases.count]
        phraseTextLbl.text = "\"\(phraseDict["text"]!)\""
        phraseAuthorLbl.text = "- \(phraseDict["author"]!)"
    }
    
    func loadColors() {
        colors = [UIColor]()
        var colorHexes = [String]()
        colorHexes.append("000000")
        colorHexes.append("ffffff")
        colorHexes.append("FF0000")
        colorHexes.append("FFFF66")
        colorHexes.append("0000FF")
        colorHexes.append("00BB00")
        colorHexes.append("FF9900")
        colorHexes.append("9933FF")
        colorHexes.append("8B4513")
        colorHexes.append("FF0099")
        colorHexes.append("66CCFF")
        colorHexes.append("006600")
        
        colorHexes.sortInPlace{ $0 < $1 }
        for color in colorHexes {
            colors!.append(UIColor(hexString: color)!)
        }
    }
    
    func loadTools() {
        tools = [String]()
        tools?.append("t_spray")
        tools?.append("t_brush")
        tools?.append("t_pen")
        tools?.append("t_pencil")
        tools?.append("t_highlighter")
        tools?.append("t_chalk")
        tools?.append("t_eraser")
        tools = tools?.reverse()
    }
    
    func loadEdit() {
        startCropperForImage(toEditImage!)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == toolCollectionView {
            return tools!.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == toolCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DrawToolCell.reusableIdentifier(), forIndexPath: indexPath) as? DrawToolCell

            cell?.toolImg.image = UIImage(named: tools![indexPath.row])
            
            if indexPath.row == selectedToolIndex {
                cell?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            }
            else {
                cell?.backgroundColor = UIColor.clearColor()
            }
            
            return cell!
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == toolCollectionView {
            switch indexPath.row {
                case 6:
                    canvas!.tool = SPRAY
                    break;
                case 5:
                    canvas!.tool = BRUSH
                    break;
                case 4:
                    canvas!.tool = PEN
                    break;
                case 3:
                    canvas!.tool = PENCIL
                    break;
                case 2:
                    canvas!.tool = MARKER
                    break;
                case 1:
                    canvas!.tool = CHALK
                    break;
                case 0:
                    canvas!.tool = ERASER
                    break;
                default:
                    break;
            }
            
            selectedToolIndex = indexPath.row
            collectionView.reloadData()
            
            if self.isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
                self.stopGestureAssistant()
                self.showNextDrawingAssistantScreen()
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(chunkedColors!.count, minRows)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ColorSprayCanCell.reusableIdentifier()) as! ColorSprayCanCell
        
        if indexPath.row < chunkedColors?.count {
            cell.colors = Array(self.chunkedColors![indexPath.row])
            cell.delegate = self
        }
        else {
            cell.colors = nil
        }
        
        return cell
    }
    
    // MARK: - Layout
    
    func configureToolsLayout() {
        var width: CGFloat
        var height: CGFloat
        let spacing = CGFloat(0)
        let padding = CGFloat(0)
        
        width = toolCollectionView.frame.width
        height = width
        
        let layout = toolCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
    }
    
    // MARK: - ColorSprayCanCellDelegate
    
    func didChooseColor(color: UIColor) {
        colorBtn.backgroundColor = color
        self.canvas!.setDrawColor(color)
        hideColors(nil)
        
        if isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.showNextDrawingAssistantScreen()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if isPortrait! {
            return [.Portrait, .PortraitUpsideDown]
        }
        else {
            return [.LandscapeLeft, .LandscapeRight]
        }
    }
    
    // MARK: - PublishDelegate
    
    func didPublish() {
        Utils.runWithDelay(0.3) {
            self.onClickClose(nil)
        }
    }
    
    func didCancel() {
        
    }
    
    // MARK: - CanvasDelegate
    
    func didInteractWithCanvas() {
        if phraseContainer.alpha > 0 {
            Utils.hideView(phraseContainer)
        }
        
        configureUndoButtons()
    }
    
    func didBeginDrawingAtPoint(point: CGPoint) {
        self.stopGestureAssistant()
        
        let p = CGPointMake(point.x, self.canvasView.frame.height - point.y)
        if CGRectContainsPoint(onCanvasTuneBtn.frame, p) || CGRectContainsPoint(onCanvasColorBtn.frame, p) ||  CGRectContainsPoint(onCanvasMenuBtn.frame, p) {
            hideOnCanvasTools()
        }
    }
    
    func didDrawAtPoint(point: CGPoint) {
        let p = CGPointMake(point.x, self.canvasView.frame.height - point.y)
        if CGRectContainsPoint(onCanvasTuneBtn.frame, p) || CGRectContainsPoint(onCanvasColorBtn.frame, p) ||  CGRectContainsPoint(onCanvasMenuBtn.frame, p) {
            hideOnCanvasTools()
        }
    }
    
    func didFinishDrawingAtPoint(point: CGPoint) {
        showOnCanvasTools()
        
        if isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
            self.showNextDrawingAssistantScreen()
        }
    }
    
    func showOnCanvasTools() {
        UIView.animateWithDuration(0.3) { 
            self.onCanvasTuneBtn.alpha = 1.0
            self.onCanvasColorBtn.alpha = 1.0
            self.onCanvasMenuBtn.alpha = 1.0
        }
    }
    
    func hideOnCanvasTools() {
        UIView.animateWithDuration(0.3) {
            self.onCanvasTuneBtn.alpha = 0.2
            self.onCanvasColorBtn.alpha = 0.2
            self.onCanvasMenuBtn.alpha = 0.2
        }
    }
    
    // MARK: - ToolStackViewControllerDelegate
    
    func toolStackController(toolStackController: ToolStackController, didFinishWithImage image: UIImage) {
        self.dismissViewControllerAnimated(true, completion: {
            self.canvas!.clearDrawingLayer()
            self.canvas!.setBackground(image)
            
            if self.isDrawAssistantMode { // If we're showing the drawing assistant, move to next stage.
                self.showNextDrawingAssistantScreen()
            }
        })
    }
    
    func toolStackControllerDidFail(toolStackController: ToolStackController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func toolStackControllerDidCancel(toolStackController: ToolStackController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Setup
    
    func setupCocos2D() {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Setting up IntroScene")
        
        canvasScene = IntroScene(self.canvasView.bounds)
        
        if CCDirector.sharedDirector().runningScene != nil {
            CCDirector.sharedDirector().replaceScene(canvasScene)
        }
        else {
            CCDirector.sharedDirector().pushScene(canvasScene)
        }
        
        canvas = canvasScene!.canvas
        canvas?.delegate = self
        
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] IntroScene set up - \(canvasScene)")
        
        // Setup default colors.
        let color = UIColor.blackColor()
        colorBtn.backgroundColor = color
        canvas?.setDrawColor(color)
        
        // Setup canvas view.
        Utils.applyCanvasShadowEffectToView(self.canvasView)
    }
    
    func setupColorConstants() {
        minRows = Int(self.colorsTableView.frame.height / self.colorsTableView.rowHeight) + 2
        chunkedColors = colors!.chunk(withDistance: App.ColorsPerRow)
    }
}
