//
//  IntroPresentationController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/17/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class IntroPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate
{
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController)
    {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        presentedViewController.modalPresentationStyle = .Custom
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect
    {
        var presentedViewFrame = CGRectZero
        if let containerBounds = containerView?.bounds {
            let scale: CGFloat = 0.45
            presentedViewFrame.size = CGSizeMake(containerBounds.size.width, floor(containerBounds.size.height * scale))
            presentedViewFrame.origin.y = containerBounds.origin.y + containerBounds.size.height - presentedViewFrame.size.height // Move frame to the bottom of the screen
        }
        
        return presentedViewFrame
    }
    
    // MARK: UIViewControllerTransitioningDelegate Protocol Methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController?
    {
        return self
    }
    
    override func presentationTransitionWillBegin()
    {
        // Add an underlay that dismisses the presented view controller when the user taps outside of the Intro slides.
        if let containerView = self.containerView {
            let underlayView = UIView(frame: containerView.bounds)
            underlayView.backgroundColor = UIColor.clearColor()
            underlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(underlayViewTapped(_:))))
            
            containerView.addSubview(underlayView)
        }
    }
    
    // MARK: Helpers
    
    func underlayViewTapped(sender: UITapGestureRecognizer)
    {
        let dismissalBlock = (presentedViewController as? IntroPageViewController)?.dismissalBlock
        presentingViewController.dismissViewControllerAnimated(true, completion: dismissalBlock)
    }
    
    private var underlayView: UIView!
}
