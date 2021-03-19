//
//  OMDBResolver.swift
//  Sample
//
//  Created by user2o on 19.03.21.
//

import SwiftUI

/// A SwiftUI observable that will resolve a SearchResultItem to OMDBItem.
/// If resolving fails it provides an error message which is also published to update the UI automatically.
class OMDBResolver: ObservableObject {
    
    /// The resolved item with details from OMDB API.
    /// Is set async when the download has completed.
    @Published var item: OMDBItem?
    
    /// A potential error message which is set in case the
    /// resolvation failed, e.g. timeouts, server errors etc.
    @Published var error: String? = nil
    
    /// Initiates the resolver and immediately starts working with the
    /// provided parameter asynchroneously on another thread.
    /// - Parameter searchResult: the selected result item from the search
    init(searchResult: SearchResultItem) {
        // Going async ...
        DispatchQueue.global().async {
            // ... and start resolving.
            self.resolve(searchResult)
        }
    }
    
    /// Queries the OMDB API to obtain details about the passed in search result item.
    /// This will either result in setting the @Published item whith auto updates the UI.
    /// In case the request **fails** this function will set the @Published error message.
    /// - Parameter searchResult: the search result item to query details for
    func resolve(_ searchResult: SearchResultItem) {
        
        do {
            // Create the connector and query details.
            let details = try OMDBConnector().detailsFor(item: searchResult)
            
            DispatchQueue.main.async {
                //
                self.item = details
            }
        }
        catch NetworkError.failure(let message) {
            // The request failed and here is a probably detailed reason.
            // Lets publish it to update the UI accordingly.
            DispatchQueue.main.async {
                self.error = message
            }
        }
        catch {
            // Something else went wrong.
            // Lets use a more generic error message and append the hopefully useful description.
            DispatchQueue.main.async {
                self.error = "Unable to fetch data. Please try again. \(error.localizedDescription)"
            }
        }
    }
}
