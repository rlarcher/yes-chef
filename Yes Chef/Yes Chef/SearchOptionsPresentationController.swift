//
//  SearchOptionsPresentationController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/3/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SearchOptionsPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate
{
    var presentationFrame = CGRectZero
    var passthroughViews = [UIView]() {
        didSet {
            passthroughOverlay.listeningViews = passthroughViews
            passthroughOverlay.frame = passthroughViews[0].frame    // In our case, this will be the search bar.
        }
    }
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController)
    {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        presentedViewController.modalPresentationStyle = .Custom

        passthroughOverlay = PassthroughOverlay()
        passthroughOverlay.backgroundColor = UIColor.clearColor()
    }
    
    override func containerViewDidLayoutSubviews()
    {
        if let containerView = self.containerView {
            containerView.insertSubview(passthroughOverlay, atIndex: containerView.subviews.count)
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect
    {
        return presentationFrame
    }
    
    // MARK: UIViewControllerTransitioningDelegate Protocol Methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController?
    {
        return self
    }
    
    private var passthroughOverlay: PassthroughOverlay!
}
