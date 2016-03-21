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
//    @IBOutlet var view: UIView!
//    @IBOutlet var barView: CustomCommandBar!
    
    @IBOutlet weak var commandsButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    var customDelegate: CustomCommandBarDelegate?
    
//    required init?(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)
//        commonInit()
//        
//        let bundle = NSBundle(forClass: self.dynamicType)
//        bundle.loadNibNamed("CustomCommandBar", owner: self, options: nil)
//        self.addSubview(view)
//    }
//    
//    override init(frame: CGRect)
//    {
//        super.init(frame: frame)
//        commonInit()
//    }
//    
//    func commonInit()
//    {
//        let bundle = NSBundle(forClass: self.dynamicType)
//        let nib = UINib(nibName: "CustomCommandBar", bundle: bundle)
//        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
//
//        // use bounds not frame or it'll be offset
//        view.frame = bounds
//        
//        // Make the view stretch with containing view
//        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
//        // Adding custom subview on top of our view (over any custom drawing > see note below)
//        addSubview(view)
//    }
    
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
