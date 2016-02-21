//
//  UINavigationController+PopThenPush.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/03.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import UIKit


extension UINavigationController
{
    /**
    Simultaneously pops from the top of the navigation controller stack and pushes on a new view controller, without any intermediate transition.
    
    For example, in a navigation stack of A - B - C where we want to transition to a stack of A - B - D.
    Directly setting the navigation stack as we do here will appear to transition directly from C to D, instead of transitioning from C to B to D.
    
    Should be called from the main thread.
    
    - parameter newViewController: New view controller to replace the current top of the stack.
    - parameter animated:          If true, transition will be animated, otherwise not.
    */
    func popThenPushViewController(newViewController: UIViewController, animated: Bool)
    {
        var newNavigationStack = self.viewControllers
        newNavigationStack.removeLast() // Pop
        newNavigationStack.append(newViewController) // Push
        
        self.setViewControllers(newNavigationStack, animated: animated) // Set stack
    }
    
    func popToRootThenPushViewController(newViewController: UIViewController, animated: Bool)
    {
        if let rootViewController = viewControllers.first {
            let newNavigationStack = [rootViewController, newViewController]
            self.setViewControllers(newNavigationStack, animated: animated)
        }
    }
}
