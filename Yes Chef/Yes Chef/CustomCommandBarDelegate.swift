//
//  CustomCommandBarDelegate.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/21/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

protocol CustomCommandBarDelegate
{
    func commandBarDidSelectCommandsButton(commandBar: SAYCommandBar)
    func commandBarDidSelectPreviousButton(commandBar: SAYCommandBar)
    func commandBarDidSelectPlayPauseButton(commandBar: SAYCommandBar)
    func commandBarDidSelectForwardButton(commandBar: SAYCommandBar)
    func commandBarDidSelectMicButton(commandBar: SAYCommandBar)
}
