//
//  Int+Utils.swift
//  Yes Chef
//
//  Created by Adam Larsen on 2016/20/2.
//  Copyright © 2016 Conversant Labs. All rights reserved.
//

import Foundation

extension Int
{
    func withSuffix(suffix: String) -> String
    {
        return self.withSuffix(suffix, plural: suffix + "s")
    }
    
    // Concatenates self with the given suffix, and pluralizes the suffix if needed.
    func withSuffix(suffix: String, plural: String) -> String
    {
        if self == 1 {
            return "\(self) \(suffix)"
        }
        else {
            return "\(self) \(plural)"
        }
    }
}
