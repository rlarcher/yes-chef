//
//  TopTabBarController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/4/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

enum TabBarPosition
{
    case Top
    case Bottom
}

class TopTabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        // Wrap our view in an empty view, but with space for the relocated tab bar.
        let wrapperView = UIView(frame: view.frame)
        
        let contentView = view
        contentView.frame.origin.y += barOffset
        contentView.frame.size.height -= barOffset
        wrapperView.addSubview(contentView)
        
        // Add an underlay beneath the Tab Bar. With the tab bar no longer within the bounds of its parent view, taps won't normally be sent to the tab bar. Add our own view to make sure those taps make it to the tab bar.
        let underlayView = TapInterceptorView(frame: CGRectMake(wrapperView.frame.origin.x, wrapperView.frame.origin.y, wrapperView.frame.size.width, barOffset))
        underlayView.listeningViews = [tabBar]
        wrapperView.addSubview(underlayView)
        
        view = wrapperView
        self.contentView = contentView
        self.underlayView = underlayView
        
        super.viewDidLoad()
    }
    
    // We're not strictly allowed to mess with the tab bar positions, per Apple's documentation. For instance, we can't add constraints to it. Next best thing is forcing the frame positions to where we want them to be.
    override func viewDidLayoutSubviews()
    {
        refreshTabBarPosition()
    }
    
    func setTabBarToTop()
    {
        contentView.frame.origin.y = barOffset
        if navigationController?.navigationBar.hidden == true {
            underlayView.frame.origin.y = view.frame.origin.y
        }
        else {
            underlayView.frame.origin.y = view.frame.origin.y + navigationController!.navigationBar.frame.height
        }
        
        tabBarPosition = .Top
        refreshTabBarPosition()
    }
    
    func setTabBarToBottom()
    {
        contentView.frame.origin.y = view.frame.origin.y
        underlayView.frame.origin.y = view.frame.size.height - barOffset
        underlayView.backgroundColor = UIColor.redColor()
        
        tabBarPosition = .Bottom
        refreshTabBarPosition()
    }
    
    private func refreshTabBarPosition()
    {
        if tabBarPosition == .Top {
            if navigationController?.navigationBar.hidden == true {
                tabBar.frame.origin.y = -barOffset  // This moves the tab bar outside of its containing view. But at least we're guaranteed not to interfere with any content.
            }
            else {
                tabBar.frame.origin.y = -barOffset + navigationController!.navigationBar.frame.height
            }
        }
        else {
            tabBar.frame.origin.y = view.frame.size.height - barOffset
        }
    }
    
    private var barOffset: CGFloat {
        return tabBar.frame.size.height
    }
    
    private var contentView: UIView!
    private var underlayView: UIView!
    private var tabBarPosition: TabBarPosition = .Top
}

class TapInterceptorView: UIView
{
    var listeningViews = [UIView]()
    
    // Hack to send taps to a view that is hanging outside of its parent view (e.g. a Tab Bar that's been moved above its content)
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        if let hitView = super.hitTest(point, withEvent: event) where hitView == self {
            for listeningView in listeningViews {
                if let hitListeningView = listeningView.hitTest(convertPoint(point, toView: listeningView), withEvent: event) {
                    return hitListeningView
                }
            }
            
            return hitView
        }
        else {
            return nil
        }
    }
}
