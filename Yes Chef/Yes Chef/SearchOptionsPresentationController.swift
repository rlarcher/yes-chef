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
            passthroughOverlay.passthroughViews = passthroughViews
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

class PassthroughOverlay: UIView
{
    var passthroughViews = [UIView]()
    
    // Hack to allow the presentedVC's taps to be handled by the underlying presentingVC. Typically, the popover's container view will prevent any taps from trickling down.
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        if let hitView = super.hitTest(point, withEvent: event) where hitView == self {
            for passthroughView in passthroughViews {
                if let hitPassthroughView = passthroughView.hitTest(convertPoint(point, toView: passthroughView), withEvent: event) {
                    return hitPassthroughView
                }
            }
            
            return hitView
        }
        else {
            return nil
        }
    }
}
