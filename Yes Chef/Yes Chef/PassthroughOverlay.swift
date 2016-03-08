//
//  PassthroughOverlay.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/8/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class PassthroughOverlay: UIView
{
    var listeningViews = [UIView]()
    
    // Hack to allow the presentedVC's taps to be handled by the underlying presentingVC. Typically, the popover's container view will prevent any taps from trickling down.
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        if let hitView = super.hitTest(point, withEvent: event) where hitView == self {
            for listeningView in listeningViews {
                if let hitListeningView = listeningView.hitTest(convertPoint(point, toView: listeningView), withEvent: event) {
                    return hitListeningView
                }
            }
            
            return hitView
        }
        else {
            return nil
        }
    }
}
