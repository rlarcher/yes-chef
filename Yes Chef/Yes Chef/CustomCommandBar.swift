//
//  CustomCommandBar.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/21/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class CustomCommandBar: SAYCommandBar
{
    @IBOutlet weak var commandsButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    var customDelegate: CustomCommandBarDelegate?
    
    @IBAction func commandsButtonTapped(sender: AnyObject)
    {
        customDelegate?.commandBarDidSelectCommandsButton(self)
    }
    
    @IBAction func previousButtonTapped(sender: AnyObject)
    {
        customDelegate?.commandBarDidSelectPreviousButton(self)
    }
    
    @IBAction func playPauseButtonTapped(sender: AnyObject)
    {
        customDelegate?.commandBarDidSelectPlayPauseButton(self)
    }
    
    @IBAction func forwardButtonTapped(sender: AnyObject)
    {
        customDelegate?.commandBarDidSelectForwardButton(self)
    }
    
    @IBAction func micButtonTapped(sender: AnyObject)
    {
        customDelegate?.commandBarDidSelectMicButton(self)
    }
}
