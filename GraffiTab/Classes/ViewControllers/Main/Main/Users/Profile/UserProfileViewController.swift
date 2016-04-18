//
//  UserProfileViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 14/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import CSStickyHeaderFlowLayout

class UserProfileViewController: ListFullStreamablesViewController {

    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var header: UserCollectionParallaxHeader?
    var titleView: UILabel?
    var user: GTUser?
    var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        setupNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 405)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickEdit(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EditProfileViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func onClickFollow(sender: AnyObject) {
        
    }
    
    func onClickBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func isMe() -> Bool {
        return user?.id == GTSettings.sharedInstance.user!.id
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTUserManager.getUserStreamables(user!.id!, offset: offset, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        // Configure header alpha.
        let minScrollDistance = CGFloat(100)
        let maxScrollDistance = CGFloat(145)
        let scrollY = collectionView.contentOffset.y
        let distanceToTravel = maxScrollDistance - minScrollDistance
        
        let offset = maxScrollDistance - scrollY
        let alpha = (1.0 * offset) / distanceToTravel
        navigationBar.backgroundColor = UIColor(hexString: Colors.Main)?.colorWithAlphaComponent(1.0 - alpha)
        titleView!.alpha = 1.0 - alpha
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == CSStickyHeaderParallaxHeader {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: UserCollectionParallaxHeader.reusableIdentifier(), forIndexPath: indexPath) as? UserCollectionParallaxHeader
            
            header!.setItem(user)
//            view.delegate = self
            
            return header!
        }
        
        assert(false, "Unsupported collection view supplementary element.")
    }
    
    // MARK: - Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView.registerNib(UINib(nibName: UserCollectionParallaxHeader.reusableIdentifier(), bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: UserCollectionParallaxHeader.reusableIdentifier())
    }
    
    func setupButtons() {
        followBtn.layer.cornerRadius = followBtn.frame.size.width / 2
        followBtn.layer.shadowRadius = 3.0
        followBtn.layer.shadowColor = UIColor.blackColor().CGColor;
        followBtn.layer.shadowOffset = CGSizeMake(1.6, 1.6)
        followBtn.layer.shadowOpacity = 0.5
        followBtn.layer.masksToBounds = false
        followBtn.backgroundColor = UIColor(hexString: Colors.Green)
    }
    
    func setupNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBar.backgroundColor = .clearColor()
        navigationBar.shadowImage = UIImage()
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -14
        let backBtn = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(onClickBack))
        navigationBar.topItem?.leftBarButtonItems = [negativeSpacer, backBtn]
        
        titleView = UILabel()
        titleView!.text = "Georgi Christov"
        titleView!.textColor = .whiteColor()
        titleView!.textAlignment = .Center
        titleView!.font = UIFont.boldSystemFontOfSize(17)
        titleView!.frame = CGRectMake(0, 0, self.view.frame.width - 120, 21)
        navigationBar.topItem?.titleView = titleView
        titleView!.alpha = 0.0
    }
}
