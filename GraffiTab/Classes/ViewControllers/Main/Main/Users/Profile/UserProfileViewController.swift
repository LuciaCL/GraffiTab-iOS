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

    @IBOutlet weak var editBtn: UIButton!
    
    var user: GTUser?
    var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkEditEnabled()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 410)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickEdit(sender: AnyObject) {
        
    }
    
    func checkEditEnabled() {
        
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTUserManager.getUserStreamables(user!.id!, offset: offset, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == CSStickyHeaderParallaxHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: UserCollectionParallaxHeader.reusableIdentifier(), forIndexPath: indexPath) as! UserCollectionParallaxHeader
            
            view.setItem(user)
//            view.delegate = self
            
            return view
        }
        
        assert(false, "Unsupported collection view supplementary element.")
    }
    
    // MARK: - Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView.registerNib(UINib(nibName: UserCollectionParallaxHeader.reusableIdentifier(), bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: UserCollectionParallaxHeader.reusableIdentifier())
    }
    
    func setupButtons() {
        editBtn.layer.cornerRadius = editBtn.frame.size.width / 2
        editBtn.layer.shadowRadius = 3.0
        editBtn.layer.shadowColor = UIColor.blackColor().CGColor;
        editBtn.layer.shadowOffset = CGSizeMake(1.6, 1.6)
        editBtn.layer.shadowOpacity = 0.5
        editBtn.layer.masksToBounds = false
        editBtn.backgroundColor = UIColor(hexString: Colors.Main)
    }
}
