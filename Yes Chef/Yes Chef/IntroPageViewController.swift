//
//  IntroPageViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/16/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class IntroPageViewController: UIPageViewController, IntroPageEventHandler, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    var dismissalBlock: (() -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // TODO: If we want to add any more customization (like positioning), probably better off just making my own subclass of UIPageControl
        let pageControlAppearance = UIPageControl.appearanceWhenContainedInInstancesOfClasses([IntroPageViewController.self])
        pageControlAppearance.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControlAppearance.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        
        if
            let welcomeIntroVC = storyboard?.instantiateViewControllerWithIdentifier("WelcomeIntroViewController") as? WelcomeIntroViewController,
            let searchIntroVC = storyboard?.instantiateViewControllerWithIdentifier("SearchIntroViewController") as? SearchIntroViewController,
            let preparationIntroVC = storyboard?.instantiateViewControllerWithIdentifier("PreparationIntroViewController") as? PreparationIntroViewController
        {
            welcomeIntroVC.presentationIndex = 0
            welcomeIntroVC.eventHandler = self
            
            searchIntroVC.presentationIndex = 1
            searchIntroVC.eventHandler = self
            
            preparationIntroVC.presentationIndex = 2
            preparationIntroVC.eventHandler = self
            
            pageViewControllers = [welcomeIntroVC, searchIntroVC, preparationIntroVC]
            setViewControllers([welcomeIntroVC], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    // MARK: IntroPageEventHandler Protocol Methods
    
    func requestedNextPage()
    {
        if currentIndex < (pageViewControllers.count - 1) {
            currentIndex += 1
            setViewControllers([pageViewControllers[currentIndex]], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    // "Discard" the intro scene. Don't forget to set a new root topic in the conversation manager.
    func requestedExitIntro()
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: dismissalBlock)
    }
    
    // MARK: UIPageViewControllerDataSource Protocol Methods
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        if let index = (viewController as? IntroPage)?.presentationIndex where index > 0 {
            return pageViewControllers[index - 1]
        }
        else {
            // This is the first view controller. The one before this is nil.
            return nil
        }
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        if let index = (viewController as? IntroPage)?.presentationIndex where index < (pageViewControllers.count - 1) {
            return pageViewControllers[index + 1]
        }
        else {
            // This is the last view controller. The one after this is nil.
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 3
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return currentIndex
    }
    
    // MARK: UIPageViewControllerDelegate Protocol Methods
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController])
    {
        if let newIndex = (pendingViewControllers.first as? IntroPage)?.presentationIndex {
            currentIndex = newIndex
        }
    }
    
    private var pageViewControllers: [UIViewController]!
    private var currentIndex: Int = 0
}

protocol IntroPageEventHandler
{
    func requestedNextPage()
    func requestedExitIntro()
}
