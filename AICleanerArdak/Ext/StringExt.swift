//
//  StringExt.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 22.01.2025.
//

import Foundation

extension String {
    var unescapingUnicodeCharacters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, "Any-Hex/Java" as NSString, true)
        return mutableString as String
    }
}
