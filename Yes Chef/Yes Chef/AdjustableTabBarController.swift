//
//  AdjustableTabBarController.swift
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

class AdjustableTabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Wrap our view in an empty view, but with space for the relocated tab bar.
        let wrapperView = UIView(frame: view.frame)
        
//        let frames = framesWhenTabBarAtTop()
        
        let contentView = view
//        contentView.frame.origin.y += barOffset
//        contentView.frame.size.height -= barOffset
//        contentView.frame = frames.contentFrame
        contentView.backgroundColor = UIColor.greenColor()
        wrapperView.addSubview(contentView)
        
        // Add an underlay beneath the Tab Bar. With the tab bar no longer within the bounds of its parent view, taps won't normally be sent to the tab bar. Add our own view to make sure those taps make it to the tab bar.
//        let underlayView = TapInterceptorView(frame: CGRectMake(wrapperView.frame.origin.x, wrapperView.frame.origin.y, wrapperView.frame.size.width, barOffset))
        let underlayView = PassthroughOverlay(frame: tabBar.frame)
        underlayView.listeningViews = [tabBar]
        underlayView.backgroundColor = UIColor.redColor()
        wrapperView.addSubview(underlayView)
        
        view = wrapperView
        view.backgroundColor = UIColor.yellowColor()
        self.contentView = contentView
        self.underlayView = underlayView
    }
    
    // We're not strictly allowed to mess with the tab bar positions, per Apple's documentation. For instance, we can't add constraints to it. Next best thing is forcing the frame positions to where we want them to be.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
//        refreshTabBarPosition()
        refreshFramePositions()
    }
    
    func setTabBarToTop()
    {
        tabBarPosition = .Top
        let frames = framesWhenTabBarAtTop()
        
        tabBar.frame = frames.tabBarFrame
        // TODO: Try converting to rect some more. view.convertRect(frames.tabBarFrame, toView: underlayView) maybe
        tabBar.frame.origin.y -= frames.tabBarFrame.size.height // Account for differing superviews. TODO: Cleaner/more correct way to adjust this?
//        if shouldShift {
//            tabBar.frame.origin.y += UIApplication.sharedApplication().statusBarFrame.height
//        }
        
        underlayView.frame = frames.tabBarFrame
        contentView.frame = frames.contentFrame
        
        
        
        
//        contentView.frame.origin.y = barOffset
//        if navigationController?.navigationBar.hidden == true {
//            underlayView.frame.origin.y = view.frame.origin.y
//        }
//        else {
//            underlayView.frame.origin.y = view.frame.origin.y + navigationController!.navigationBar.frame.height
//        }
//        
//        tabBarPosition = .Top
//        refreshTabBarPosition()
    }
    
    func setTabBarToBottom()
    {
        tabBarPosition = .Bottom
        let frames = framesWhenTabBarAtBottom()
        
        tabBar.frame = frames.tabBarFrame
//        tabBar.frame.origin.y += frames.tabBarFrame.size.height // Account for differing superviews. TODO: Cleaner/more correct way to adjust this?
        
        underlayView.frame = frames.tabBarFrame
        contentView.frame = frames.contentFrame
        
        
        
//        contentView.frame.origin.y = view.frame.origin.y
//        underlayView.frame.origin.y = view.frame.size.height - barOffset
////        underlayView.backgroundColor = UIColor.redColor()
//        
//        tabBarPosition = .Bottom
//        refreshTabBarPosition()
    }
    
    private func refreshFramePositions()
    {
        if tabBarPosition == .Top {
            setTabBarToTop()
        }
        else {
            setTabBarToBottom()
        }
    }
    
    private func refreshTabBarPosition()
    {
        if tabBarPosition == .Top {
            if navigationController?.navigationBar.hidden == true {
                tabBar.frame.origin.y = -barOffset  // This moves the tab bar outside of its containing view. But at least we're guaranteed not to interfere with any content.
            }
            else {
                tabBar.frame.origin.y = -barOffset + (navigationController?.navigationBar.frame.height ?? 0.0)
            }
        }
        else {
            tabBar.frame.origin.y = view.frame.size.height - barOffset
        }
    }
    
    private func framesWhenTabBarAtTop() -> (tabBarFrame: CGRect, contentFrame: CGRect)
    {
        let tabBarFrame: CGRect, contentFrame: CGRect
        
        if navigationController?.navigationBar.hidden == true {
            // Don't include navigationBar height
            tabBarFrame = CGRectMake(view.bounds.origin.x,
//                                     view.frame.origin.y - barOffset,
                                     view.bounds.origin.y,
                                     tabBar.frame.size.width,
                                     tabBar.frame.size.height)
            contentFrame = CGRectMake(tabBarFrame.origin.x,
                                      tabBarFrame.origin.y + tabBarFrame.size.height,
                                      view.frame.size.width,
                                      view.frame.size.height - tabBarFrame.size.height)
        }
        else {
            let topBarHeight = (navigationController?.navigationBar.frame.height ?? 0.0) //+ UIApplication.sharedApplication().statusBarFrame.height
            tabBarFrame = CGRectMake(view.bounds.origin.x,
//                                     view.frame.origin.y - barOffset + navBarHeight,
                                     view.bounds.origin.y + topBarHeight,
                                     tabBar.frame.size.width,
                                     tabBar.frame.size.height)
            contentFrame = CGRectMake(tabBarFrame.origin.x,
                                      tabBarFrame.origin.y + tabBarFrame.size.height,
                                      view.frame.size.width,
                                      view.frame.size.height - tabBarFrame.size.height - topBarHeight)
        }
        
        return (tabBarFrame, contentFrame)
    }
    
    private func framesWhenTabBarAtBottom() -> (tabBarFrame: CGRect, contentFrame: CGRect)
    {
        let tabBarFrame: CGRect, contentFrame: CGRect
        
        // TODO: Include status bar height?
        
        if navigationController?.navigationBar.hidden == true {
            // Don't include navigationBar height
            contentFrame = CGRectMake(view.frame.origin.x,
                                      view.frame.origin.y,
                                      view.frame.size.width,
                                      view.frame.size.height - tabBar.frame.size.height)
            tabBarFrame = CGRectMake(contentFrame.origin.x,
                                     contentFrame.origin.y + contentFrame.size.height,
                                     tabBar.frame.size.width,
                                     tabBar.frame.size.height)
        }
        else {
            let navBarHeight = navigationController?.navigationBar.frame.height ?? 0.0
            contentFrame = CGRectMake(view.frame.origin.x,
                                      view.frame.origin.y,
                                      view.frame.size.width,
                                      view.frame.size.height - tabBar.frame.size.height - navBarHeight)
            tabBarFrame = CGRectMake(contentFrame.origin.x,
                                     contentFrame.origin.y + contentFrame.size.height,
                                     tabBar.frame.size.width,
                                     tabBar.frame.size.height)
        }
        
        return (tabBarFrame, contentFrame)
    }
    
    private var barOffset: CGFloat {
        return tabBar.frame.size.height
    }
    
    private var statusBarHeight: CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.height
    }
    
    private var contentView: UIView!
    private var underlayView: UIView!
    private var tabBarPosition: TabBarPosition = .Bottom
}
