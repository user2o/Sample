//
//  String.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import Foundation

extension String {
    
    /// Uses NSRegularExpression to find and remove simple HTML tags like `<p>` and `</p>`.
    /// - Returns: the string without HTML tags
    func removeHTMLTags() -> String {
        
        // The regex pattern to find HTML tags.
        let pattern = "(?i)<[^>]*>"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: self.count)
        
        return regex.stringByReplacingMatches(in: self,
                                              options: [],
                                              range: range,
                                              withTemplate: "")
    }
}
