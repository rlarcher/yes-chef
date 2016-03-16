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
}
