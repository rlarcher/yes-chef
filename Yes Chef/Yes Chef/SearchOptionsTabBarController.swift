//
//  SearchOptionsTabBarController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/8/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SearchOptionsTabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Wrap our view in an empty view, but with space for the relocated tab bar.
        let wrapperView = UIView(frame: view.frame)
        
        let contentView = view
        //        contentView.backgroundColor = UIColor.greenColor()
        wrapperView.addSubview(contentView)
        
        // Add an underlay beneath the Tab Bar. With the tab bar no longer within the bounds of its parent view, taps won't normally be sent to the tab bar. Add our own view to make sure those taps make it to the tab bar.
        let underlayView = PassthroughOverlay(frame: tabBar.frame)
        underlayView.listeningViews = [tabBar]
        //        underlayView.backgroundColor = UIColor.redColor()
        wrapperView.addSubview(underlayView)
        
        view = wrapperView
        //        view.backgroundColor = UIColor.yellowColor()
        self.contentView = contentView
        self.underlayView = underlayView
    }
    
    // We're not strictly allowed to mess with the tab bar positions, per Apple's documentation. For instance, we can't add constraints to it. Next best thing is forcing the frame positions to where we want them to be.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        refreshFramePositions()
    }
    
    private func refreshFramePositions()
    {
        let frames = framesForTopTabBar()
        
        tabBar.frame = frames.tabBarFrame
        // TODO: Try converting to rect some more. view.convertRect(frames.tabBarFrame, toView: underlayView) maybe
        tabBar.frame.origin.y -= frames.tabBarFrame.size.height // Account for differing superviews. TODO: Cleaner/more correct way to adjust this?
        
        underlayView.frame = frames.tabBarFrame
        contentView.frame = frames.contentFrame
    }
    
    private func framesForTopTabBar() -> (tabBarFrame: CGRect, contentFrame: CGRect)
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
    
    private var barOffset: CGFloat {
        return tabBar.frame.size.height
    }
    
    private var statusBarHeight: CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.height
    }
    
    private var contentView: UIView!
    private var underlayView: UIView!
}
