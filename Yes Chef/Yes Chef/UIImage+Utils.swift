//
//  UIImage+Utils.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/17/3.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

extension UIImage
{
    convenience init(color: UIColor)
    {
        let rect = CGRectMake(0, 0, 1, 1)
        
        UIGraphicsBeginImageContext(rect.size)
            color.setFill()
            UIRectFill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(CGImage: image.CGImage!)
    }
}
