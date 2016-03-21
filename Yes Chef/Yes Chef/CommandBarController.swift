//
//  CommandBarController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/21/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class CommandBarController: SAYCommandBarController, CustomCommandBarDelegate
{
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
    
    private func commonInit()
    {
        CommandBarController.underlyingInstance = self
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        if let customCommandBar = bundle.loadNibNamed("CustomCommandBar", owner: nil, options: nil).first as? CustomCommandBar {
            customCommandBar.customDelegate = self
            self.commandBar = customCommandBar
        }
    }
    
    // TODO: Ideally we would do this via SAYConversationManager.systemManager
    static func setPlaybackControlsDelegate(delegate: PlaybackControlsDelegate?)
    {
        if let instance = CommandBarController.underlyingInstance {
            instance.playbackControlsDelegate = delegate
        }
        else {
            assert(false, "Tried to set playbackControlsDelegate before initializing CustomCommandBarController!")
        }
    }
    
    static func updatePlaybackState(shouldDisplayPlayIcon shouldDisplayPlayIcon: Bool, previousEnabled: Bool, forwardEnabled: Bool)
    {
        if let instance = CommandBarController.underlyingInstance {
            dispatch_async(dispatch_get_main_queue()) {
                (instance.commandBar as? CustomCommandBar)?.previousButton.enabled = previousEnabled
                (instance.commandBar as? CustomCommandBar)?.forwardButton.enabled = forwardEnabled
                (instance.commandBar as? CustomCommandBar)?.playPauseButton.enabled = true
                
                if shouldDisplayPlayIcon {
                    (instance.commandBar as? CustomCommandBar)?.playPauseButton.setImage(UIImage(named: "play"), forState: .Normal)
                }
                else {
                    (instance.commandBar as? CustomCommandBar)?.playPauseButton.setImage(UIImage(named: "pause"), forState: .Normal)
                }
            }
        }
    }
    
    // MARK: CustomCommandBarDelegate Protocol Methods
    
    func commandBarDidSelectCommandsButton(commandBar: SAYCommandBar)
    {
        super.commandBarDidSelectCommandMenu(commandBar)
    }
    
    func commandBarDidSelectPreviousButton(commandBar: SAYCommandBar)
    {
        playbackControlsDelegate?.commandBarRequestedPreviousPlaybackControl()
    }
    
    func commandBarDidSelectPlayPauseButton(commandBar: SAYCommandBar)
    {
        playbackControlsDelegate?.commandBarRequestedPlayPausePlaybackControl()
    }
    
    func commandBarDidSelectForwardButton(commandBar: SAYCommandBar)
    {
        playbackControlsDelegate?.commandBarRequestedForwardPlaybackControl()
    }
    
    func commandBarDidSelectMicButton(commandBar: SAYCommandBar)
    {
        super.commandBarDidSelectMicrophone(commandBar)
    }
    
    // MARK: Helpers
    
    private var playbackControlsDelegate: PlaybackControlsDelegate? {
        didSet {
            let playbackButtonsEnabled = (playbackControlsDelegate != nil)
            dispatch_async(dispatch_get_main_queue()) {
                (self.commandBar as? CustomCommandBar)?.previousButton.enabled = playbackButtonsEnabled
                (self.commandBar as? CustomCommandBar)?.forwardButton.enabled = playbackButtonsEnabled
                (self.commandBar as? CustomCommandBar)?.playPauseButton.enabled = playbackButtonsEnabled
            }
        }
    }
    
    static private var underlyingInstance: CommandBarController?
}

protocol PlaybackControlsDelegate
{
    func commandBarRequestedPreviousPlaybackControl()
    func commandBarRequestedForwardPlaybackControl()
    func commandBarRequestedPlayPausePlaybackControl()
}
