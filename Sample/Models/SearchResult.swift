//
//  SearchResult.swift
//  SimpleExample
//
//  Created by user2o on 07.03.21.
//

import Foundation

struct SearchResult: Codable {
    
    enum CodingKeys: String, CodingKey {
        case response = "Response", search = "Search"
        case totalResults
    }
    
    let response, totalResults: String
    let search: [SearchResultItem]
    
    var moreAvailable: Bool {
        let totalCount = Int(totalResults) ?? 0
        return search.count < totalCount
    }
    
    var nextPage: Int {
        
        let itemsPerPage: Double = 10
        
        guard let totalResults = Double(totalResults) else { return 1 }
        let totalPages = Int(ceil(totalResults/itemsPerPage))
        
        let downloaded = Double(search.count)
        let downloadedPages = Int(ceil(downloaded/itemsPerPage))
        
        let nextPage = downloadedPages + 1
        
        return min(nextPage, totalPages)
    }
    
    /// Returns a SearchResult containing the items passed in as parameter plus the current search items.
    /// - Parameter items: items that should also be in the current SearchResult
    /// - Returns: a SearchResult with combined search items
    func append(search items: [SearchResultItem]?) -> SearchResult {
        guard let items = items else { return self }
        return SearchResult(response: response, totalResults: totalResults, search: items + search)
    }
}
