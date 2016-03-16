//
//  SearchIntroViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/16/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class SearchIntroViewController: UIViewController, IntroPage
{
    var presentationIndex: Int = 0 // To be set by the page view controller.    
    var eventHandler: IntroPageEventHandler?    
    
    @IBAction func continueButtonTapped(sender: AnyObject)
    {
        eventHandler?.requestedNextPage()
    }
    
    @IBAction func skipButtonTapped(sender: AnyObject)
    {
        eventHandler?.requestedExitIntro()
    }
}
