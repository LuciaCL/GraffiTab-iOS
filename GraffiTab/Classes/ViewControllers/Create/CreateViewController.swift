//
//  CreateViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Photos

class CreateViewController: CCViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, ColorSprayCanCellDelegate {

    @IBOutlet weak var toolCollectionView: UICollectionView!
    @IBOutlet weak var canvasContainerXconstraint: NSLayoutConstraint!
    @IBOutlet weak var colorsTrailingconstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasXconstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasYconstraint: NSLayoutConstraint!
    @IBOutlet weak var colorsTableView: UITableView!
    @IBOutlet weak var drawingContainer: UIView!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var pointWidthSlider: UISlider!
    
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
    var minRows: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        isPortrait = self.view.frame.width < self.view.frame.height
        isMenuOpen = false
        isColorsOpen = false
        
        setupCocos2D()
        setupMenuRecognizer()
        
        loadColors()
        setupColorConstants()
        
        loadTools()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
            
            configureToolsLayout()
            
            Utils.runWithDelay(0.5, block: { () in
                self.hintMenu()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickEnhance(sender: AnyObject?) {
        
    }
    
    @IBAction func onClickColor(sender: AnyObject?) {
        handleSwipeLeftGesture(nil)
        
        showColors()
    }
    
    @IBAction func onClickClose(sender: AnyObject?) {
        super.close(sender)
    }
    
    @IBAction func onClickChangeBackground(sender: AnyObject) {
        // Ask for photos library.
        PHPhotoLibrary.requestAuthorization { status in
            dispatch_async(dispatch_get_main_queue(),{
                switch status {
                    case .Authorized:
                        self.askForImage()
                        break
                    case .Restricted, .Denied:
                        DialogBuilder.showOKAlert("We need your permission to access the photos library. Please enable this in Settings", title: App.Title)
                        break
                    default:
                        // place for .NotDetermined - in this callback status is already determined so should never get here
                        break
                }
            })
        }
    }
    
    @IBAction func onLongClickCollectionView(sender: AnyObject) {
        let recognizer = sender as! UIGestureRecognizer
        
        if recognizer.state == .Began {
            let p = recognizer.locationInView(toolCollectionView)
            let indexPath = toolCollectionView.indexPathForItemAtPoint(p)
            if (indexPath == nil){
                print("Couldn't find index path")
            } else {
                if indexPath?.row == 0 {
                    UIActionSheet.showInView(view, withTitle: "What would you like to do?", cancelButtonTitle: "Cancel", destructiveButtonTitle: "Clear canvas", otherButtonTitles: ["Clear background", "Clear drawing layer"], tapBlock: { (actionSheet, index) in
                        if index == 0 {
                            self.canvas!.clearCanvas()
                        }
                        else if index == 1 {
                            self.canvas!.clearBackground()
                        }
                        else if index == 2 {
                            self.canvas!.clearDrawingLayer()
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Menus
    
    func hintMenu() {
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasXconstraint.constant = 20
            self.canvasYconstraint.constant = 20
            self.canvasView.superview!.setNeedsUpdateConstraints()
            self.canvasView.superview!.layoutIfNeeded()
        }, completion: { (finished) in
            if finished {
                UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
                    self.canvasXconstraint.constant = 0
                    self.canvasYconstraint.constant = 0
                    self.canvasView.superview!.setNeedsUpdateConstraints()
                    self.canvasView.superview!.layoutIfNeeded()
                }, completion: nil)
            }
        })
    }
    
    func handleSwipeRightGesture(recognizer: UIGestureRecognizer?) {
        if isColorsOpen! {
            hideColors()
        }
        else if !isMenuOpen! {
            showMenu()
        }
    }
    
    func handleSwipeLeftGesture(recognizer: UIGestureRecognizer?) {
        if isMenuOpen! {
            hideMenu()
        }
        else if !isColorsOpen! {
            showColors()
        }
    }
    
    func showMenu() {
        isMenuOpen = true
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasXconstraint.constant = 55
            self.canvasYconstraint.constant = 55
            self.canvasView.superview!.setNeedsUpdateConstraints()
            self.canvasView.superview!.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideMenu() {
        isMenuOpen = false
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasXconstraint.constant = 0
            self.canvasYconstraint.constant = 0
            self.canvasView.superview!.setNeedsUpdateConstraints()
            self.canvasView.superview!.layoutIfNeeded()
            }, completion: nil)
    }
    
    func showColors() {
        self.isColorsOpen = true
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasContainerXconstraint.constant = -self.colorsTableView.frame.width
            self.colorsTrailingconstraint.constant = 0
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideColors() {
        self.isColorsOpen = false
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasContainerXconstraint.constant = 0
            self.colorsTrailingconstraint.constant = -self.colorsTableView.frame.width
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    // MARK: - Images
    
    override func didChooseImage(image: UIImage?) {
        canvas!.setBackground(image)
    }
    
    override func cropAspectRatio() -> CGSize {
        let view = self.canvasView != nil ? self.canvasView : self.view;
        return CGSizeMake(view.frame.size.width, view.frame.size.width / (view.frame.size.width / view.frame.size.height))
    }
    
    // MARK: - Loading
    
    func loadColors() {
        colors = [UIColor]()
        colors?.append(UIColor(hexString: "000000")!)
        colors?.append(UIColor(hexString: "56ca83")!)
        colors?.append(UIColor(hexString: "83ca54")!)
        colors?.append(UIColor(hexString: "5bc4ca")!)
        colors?.append(UIColor(hexString: "844db3")!)
        colors?.append(UIColor(hexString: "c25c9e")!)
        colors?.append(UIColor(hexString: "c24b4f")!)
        colors?.append(UIColor(hexString: "c9764e")!)
        colors?.append(UIColor(hexString: "b1b35f")!)
        colors?.append(UIColor(hexString: "ffffff")!)
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
        }
    }
    
    // MArk: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(chunkedColors!.count, minRows!)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ColorSprayCanCell.reusableIdentifier()) as! ColorSprayCanCell
        
        if indexPath.row < chunkedColors?.count {
            cell.colors = Array(self.chunkedColors![indexPath.row])
            cell.delegate = self
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
        hideColors()
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
    
    // MARK: - Setup
    
    func setupCocos2D() {
        canvasScene = IntroScene(self.canvasView.bounds)
        
        if CCDirector.sharedDirector().runningScene != nil {
            CCDirector.sharedDirector().replaceScene(canvasScene)
        }
        else {
            CCDirector.sharedDirector().pushScene(canvasScene)
        }
        
        canvas = canvasScene!.canvas
        
        // Setup default colors.
        let color = UIColor.blackColor()
        colorBtn.backgroundColor = color
        canvas?.setDrawColor(color)
        
        // Setup canvas view.
        Utils.applyCanvasShadowEffectToView(self.canvasView)
    }
    
    func setupMenuRecognizer() {
        let menuOpenRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CreateViewController.handleSwipeRightGesture(_:)))
        menuOpenRecognizer.numberOfTouchesRequired = 2
        menuOpenRecognizer.delegate = self
        menuOpenRecognizer.direction = .Right
        self.view.addGestureRecognizer(menuOpenRecognizer)
        
        let menuCloseRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CreateViewController.handleSwipeLeftGesture(_:)))
        menuCloseRecognizer.numberOfTouchesRequired = 2
        menuCloseRecognizer.delegate = self
        menuCloseRecognizer.direction = .Left
        self.view.addGestureRecognizer(menuCloseRecognizer)
    }
    
    func setupColorConstants() {
        minRows = isPortrait! ? 6 : 4
        chunkedColors = colors!.chunk(withDistance: App.ColorsPerRow)
    }
}
