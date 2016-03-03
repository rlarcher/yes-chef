//
//  MenuPresentationController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/3/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class MenuPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate
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
        
            let scale: CGFloat = 0.6
            presentedViewFrame.size = CGSizeMake(floor(containerBounds.size.width * scale), containerBounds.size.height)
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
        // Add an underlay that dismisses the presented view controller the user taps outside of the Menu.
        if let containerView = self.containerView {
            let underlayView = UIView(frame: containerView.bounds)
            underlayView.backgroundColor = UIColor.clearColor()
            underlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "underlayViewTapped:"))
            
            containerView.addSubview(underlayView)
        }
    }
    
    // MARK: Helpers
    
    func underlayViewTapped(sender: UITapGestureRecognizer)
    {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private var underlayView: UIView!
}
