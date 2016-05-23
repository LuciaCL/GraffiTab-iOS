//
//  CreateViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Photos
import imglyKit
import RNFrostedSidebar
import GraffiTab_iOS_SDK

class CreateViewController: CCViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, ColorSprayCanCellDelegate, RNFrostedSidebarDelegate, PublishDelegate, CanvasDelegate {

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
    
    var toEdit: GTStreamable?
    var toEditImage: UIImage?
    
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
        
        loadColors()
        setupColorConstants()
        
        loadTools()
        loadPhrase()
        
        if toEdit != nil {
            Utils.runWithDelay(0.3, block: {
                self.loadEdit()
            })
        }
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
    
    @IBAction func onClickPublish(sender: AnyObject?) {
        let sampleImage = self.canvas?.grabFrame()
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PublishViewController") as! PublishViewController
        vc.streamableImage = sampleImage
        vc.toEdit = toEdit
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func onClickShare(sender: AnyObject?) {
        let sampleImage = self.canvas?.grabFrame()
        Utils.shareImage(sampleImage!, viewController: self)
    }
    
    @IBAction func onClickSave(sender: AnyObject?) {
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        let sampleImage = self.canvas?.grabFrame()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            UIImageWriteToSavedPhotosAlbum(sampleImage!, nil, nil, nil);
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.hideActivityView()
                
                Utils.runWithDelay(0.3, block: {
                    DialogBuilder.showSuccessAlert("Your graffiti was saved in your photos album", title: App.Title)
                })
            })
        })
    }
    
    @IBAction func onClickDone(sender: AnyObject) {
        let sideBar = RNFrostedSidebar(images: [UIImage(named: "ic_done_white")!, UIImage(named: "ic_share_white")!, UIImage(named: "ic_file_download_white")!, UIImage(named: "ic_delete_white")!])
        sideBar.delegate = self
        sideBar.showFromRight = true
        sideBar.width = 110
        sideBar.itemSize = CGSizeMake(60, 60)
        sideBar.itemBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        sideBar.show()
    }
    
    @IBAction func onClickEnhance(sender: AnyObject?) {
        let sampleImage = self.canvas?.grabFrame()
        let editorViewController = IMGLYMainEditorViewController()
        editorViewController.highResolutionImage = sampleImage
        editorViewController.initialFilterType = .None
        editorViewController.initialFilterIntensity = 0.5
        editorViewController.completionBlock = { (result, image) in
            editorViewController.dismissViewControllerAnimated(true, completion: {
                if result == .Done {
                    self.canvas!.setBackground(image)
                }
            })
        }
        
        let nav = UINavigationController(rootViewController: editorViewController)
        nav.navigationBar.barTintColor = UIColor(hexString: "#222222")
        nav.navigationBar.translucent = false
        presentViewController(nav, animated: true, completion: nil)
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
    
    @IBAction func onClickUndo(sender: AnyObject) {
        if canvas!.canUndo() {
            canvas!.undo()
        }
    }
    
    @IBAction func onClickMenu(recognizer: AnyObject?) {
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
    
    func showMenu() {
        isMenuOpen = true
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.canvasXconstraint.constant = 55
            self.canvasYconstraint.constant = 55
            self.canvasView.superview!.setNeedsUpdateConstraints()
            self.canvasView.superview!.layoutIfNeeded()
            }, completion: nil)
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
    }
    
    override func cropAspectRatio() -> CGSize {
        let view = self.canvasView != nil ? self.canvasView : self.view;
        let offset = view.frame.height > view.frame.width ? 25 : -45
        return CGSizeMake(view.frame.size.width + CGFloat(offset), view.frame.size.width / (view.frame.size.width / view.frame.size.height))
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
        hideColors(nil)
    }
    
    // MARK: - RNFrostedSidebarDelegate
    
    func sidebar(sidebar: RNFrostedSidebar!, didTapItemAtIndex index: UInt) {
        sidebar.dismissAnimated(true)
        
        Utils.runWithDelay(0.3) {
            if index == 0 {
                self.hideMenu({
                    self.onClickPublish(nil)
                })
            }
            else if index == 1 {
                self.onClickShare(nil)
            }
            else if index == 2 {
                self.onClickSave(nil)
            }
            else if index == 3 {
                self.onClickClose(nil)
            }
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
        canvas?.delegate = self
        
        // Setup default colors.
        let color = UIColor.blackColor()
        colorBtn.backgroundColor = color
        canvas?.setDrawColor(color)
        
        // Setup canvas view.
        Utils.applyCanvasShadowEffectToView(self.canvasView)
    }
    
    func setupColorConstants() {
        minRows = isPortrait! ? 6 : 4
        chunkedColors = colors!.chunk(withDistance: App.ColorsPerRow)
    }
}
