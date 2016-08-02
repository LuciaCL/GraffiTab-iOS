//
//  OnboardingViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 01/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import iCarousel

class OnboardingViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var dismissHandler: (() -> Void)?
    var screens = [OnboardingScreen]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCarousel()
        setupPageControl()
        
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
        screen.title = "Draw"
        screen.subtitle = "Some description of drawing"
        screen.screenshot = "1"
        screens.append(screen)
        
        screen = OnboardingScreen()
        screen.title = "Explore"
        screen.subtitle = "Some description of explore"
        screen.screenshot = "2"
        screens.append(screen)
        
        screen = OnboardingScreen()
        screen.title = "Follow"
        screen.subtitle = "Some description of follow"
        screen.screenshot = "3"
        screens.append(screen)
        
        screen = OnboardingScreen()
        screen.title = "Profile"
        screen.subtitle = "Some description of profile"
        screen.screenshot = "4"
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
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    func carouselItemWidth(carousel: iCarousel) -> CGFloat {
        return carousel.frame.width
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
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
}
