//
//  OnboardingViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 01/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import iCarousel

class OnboardingViewController: BackButtonViewController, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var goBtn: UIButton!
    
    var dismissHandler: (() -> Void)?
    var screens = [OnboardingScreen]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCarousel()
        setupPageControl()
        setupLabels()
        
        loadOnboarding()
    }

    @IBAction func onClickSkip(sender: AnyObject) {
        if dismissHandler != nil {
            dismissHandler!()
        }
    }
    
    // MARK: - Loading
    
    func loadOnboarding() {
        screens.removeAll()
        
        var screen = OnboardingScreen()
        screen.title = NSLocalizedString("controller_onboarding_screen_1_title", comment: "")
        screen.subtitle = NSLocalizedString("controller_onboarding_screen_1_description", comment: "")
        screen.screenshot = DeviceType.IS_IPAD ? (Orientation.isLandscape() ? "placeholder_ipad_landscape" : "placeholder_ipad_portrait") : "onboard_1"
        screens.append(screen)
        
        screen = OnboardingScreen()
        screen.title = NSLocalizedString("controller_onboarding_screen_2_title", comment: "")
        screen.subtitle = NSLocalizedString("controller_onboarding_screen_2_description", comment: "")
        screen.screenshot = DeviceType.IS_IPAD ? (Orientation.isLandscape() ? "placeholder_ipad_landscape" : "placeholder_ipad_portrait") : "onboard_2"
        screens.append(screen)
        
        screen = OnboardingScreen()
        screen.title = NSLocalizedString("controller_onboarding_screen_3_title", comment: "")
        screen.subtitle = NSLocalizedString("controller_onboarding_screen_3_description", comment: "")
        screen.screenshot = DeviceType.IS_IPAD ? (Orientation.isLandscape() ? "placeholder_ipad_landscape" : "placeholder_ipad_portrait") : "onboard_3"
        screens.append(screen)
        
        screen = OnboardingScreen()
        screen.title = NSLocalizedString("controller_onboarding_screen_4_title", comment: "")
        screen.subtitle = NSLocalizedString("controller_onboarding_screen_4_description", comment: "")
        screen.screenshot = DeviceType.IS_IPAD ? (Orientation.isLandscape() ? "placeholder_ipad_landscape" : "placeholder_ipad_portrait") : "onboard_4"
        screens.append(screen)
        
        screen = OnboardingScreen()
        screen.title = NSLocalizedString("controller_onboarding_screen_5_title", comment: "")
        screen.subtitle = NSLocalizedString("controller_onboarding_screen_5_description", comment: "")
        screen.screenshot = DeviceType.IS_IPAD ? (Orientation.isLandscape() ? "placeholder_ipad_landscape" : "placeholder_ipad_portrait") : "onboard_5"
        screens.append(screen)
        
        carousel.reloadData()
        setupPageControl()
    }
    
    // MARK: - iCarouselDelegate
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return screens.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        let screen: OnboardingScreenView
        
        if view == nil {
            screen = NSBundle.mainBundle().loadNibNamed("OnboardingScreenView", owner: self, options: nil).first as! OnboardingScreenView
        }
        else {
            screen = view as! OnboardingScreenView
        }
        
        screen.frame = carousel.bounds
        screen.item = screens[index]
        
        return screen
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .FadeMin {
            return 0.0
        }
        else if option == .FadeMinAlpha {
            return 0.3
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    func carouselItemWidth(carousel: iCarousel) -> CGFloat {
        return carousel.frame.width
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if DeviceType.IS_IPAD {
            return .All
        }
        return [.Portrait, .PortraitUpsideDown]
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            self.loadOnboarding()
            self.carousel.reloadData()
        }) { (context) in
        }
    }
    
    // MARK: - Setup
    
    func setupPageControl() {
        pageControl.numberOfPages = numberOfItemsInCarousel(carousel)
    }
    
    func setupCarousel() {
        carousel.type = .Linear;
        carousel.bounceDistance = 0.2;
        carousel.decelerationRate = 0.8;
    }
    
    func setupLabels() {
        goBtn.setTitle(NSLocalizedString("controller_onboarding_go", comment: ""), forState: .Normal)
        goBtn.titleLabel?.font = UIFont.systemFontOfSize(DeviceType.IS_IPAD ? 24 : 16)
    }
}
