//
//  NewsFeedConnector.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import Foundation
import Just
import SwiftyXML

enum NewsError: Error {
    case failure(String)
}

struct NewsFeedConnector {
    
    /// Performs a simple HTTP GET request to download an RSS feed.
    /// The downloaded feed is then parsed into objects of type News.
    /// An error is thrown containing a message in case something goes wrong.
    /// - Returns: list of parsed items as News
    public func fetch() throws -> [News] {
        
        // Get RSS feed url from settings.
        let feedURL = Settings.shared.rssFeedURL
        
        // Create an instance of this simple HTTP client called Just.
        // This instance is to be prefered over the singleton for threadding reasons.
        let just = JustOf<HTTP>()
        
        // Perform GET request to obtain feed data.
        let response = just.get(feedURL)
            
        // Catch error if there is one.
        if let error = response.error {
            throw NewsError.failure(error.localizedDescription)
        }
        
        // Extract content of response as bytes.
        guard let content = response.content else {
            throw NewsError.failure("Response has no content.")
        }
        
        // Init XML object with HTTP response content.
        let xml = XML(data: content)
        
        // Extract list of "item" nodes from XML.
        guard let items = xml?.channel.item.xmlList else {
            // TODO: handle error = "no items in feed"
            throw NewsError.failure("Response contains not a single item node.")
        }
        
        // Turn items into News objects.
        return items.compactMap { News(xml: $0) }
    }
}
