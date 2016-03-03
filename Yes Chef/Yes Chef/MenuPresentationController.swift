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
}
