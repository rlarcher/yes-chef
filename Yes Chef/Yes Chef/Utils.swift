//
//  Utils.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/02/08.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

class Utils: NSObject
{
    static func getLabelsForRating(rating: Int) -> (textLabel: String, accessibilityLabel: String) {
        switch rating {
        case 0:
            return ("☆☆☆☆☆", "0 out of 5 stars")
        case 1:
            return ("★☆☆☆☆", "1 out of 5 stars")
        case 2:
            return ("★★☆☆☆", "2 out of 5 stars")
        case 3:
            return ("★★★☆☆", "3 out of 5 stars")
        case 4:
            return ("★★★★☆", "4 out of 5 stars")
        case 5:
            return ("★★★★★", "5 out of 5 stars")
        default:
            return ("", "")
        }
    }
}
