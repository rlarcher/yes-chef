//
//  IntroViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/16/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class IntroViewController: UIViewController
{
    var introConversationTopic: IntroConversationTopic!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    func commonInit()
    {
        self.introConversationTopic = IntroConversationTopic()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        presentIntroPages()
    }
    
    // MARK: Helpers
    
    func presentIntroPages()
    {
        if let introPageViewController = storyboard?.instantiateViewControllerWithIdentifier("IntroPageViewController") as? IntroPageViewController {
            let presentationController = IntroPresentationController(presentedViewController: introPageViewController, presentingViewController: self)
            introPageViewController.transitioningDelegate = presentationController
            introPageViewController.dismissalBlock = transitionToHome
            
            presentViewController(introPageViewController, animated: true, completion: nil)
        }
    }
    
    private func transitionToHome()
    {
        if let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController {
            let newRootTopic = homeVC.homeConversationTopic
            let systemManager = SAYConversationManager.systemManager()
            systemManager.commandRegistry = newRootTopic
            systemManager.addAudioSource(newRootTopic, forTrack: SAYAudioTrackMainIdentifier)
            self.navigationController?.setViewControllers([homeVC], animated: true)
        }
    }
}
