//
//  ConversationalTabBarViewController.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/08.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

protocol ConversationalTabBarViewController
{
    func didGainFocus(completion: (() -> Void)?)
    func didLoseFocus(completion: (() -> Void)?)
}
