//
//  OMDBConnector.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

/// A simple OMDBAPI interface to search for movies and series.
/// As an example this connector uses "URLSession" to perform the HTTP requests.
struct OMDBConnector {
    
    /// OMDB API Key from settings
    private let key = Settings.shared.apiKey
    
    private enum RequestKind: String {
        case search = "https://www.omdbapi.com/?s=%@&apikey=%@&page=%d"
        case byID = "https://www.omdbapi.com/?i=%@&apikey=%@"
    }
    
    // MARK: - Public Interface
    
    /// Prepares and performs a simple HTTP GET request to download an RSS feed.
    /// The downloaded feed is then parsed into objects of type News.
    /// An error is thrown containing a message in case something goes wrong.
    /// - Returns: list of parsed items as News
    
    /// Performs a simple HTTP GET request to perform a search on omdbapi.com.
    /// The downloaded JSON is parsed into objects via codable structs.
    /// - Parameters:
    ///   - title: the term to search for
    ///   - previous: a previous search result to add new result items to
    /// - Returns: a SearchResult containing combined items, from prevous and new result
    public func search(title: String, basedOn previous: SearchResult?) throws -> SearchResult {
        
        // Determine what next page number should be used for the next request.
        // Defaults to 1 because that's the minimum on the API.
        let nextPage = previous?.nextPage ?? 1
        
        // Create the url object using the search term and page number to request.
        guard let requestURL = searchURL(with: title, page: nextPage) else {
            // Early exit when URL can't be created for whatever reason.
            throw NetworkError.failure("Unable to create URL to query API.")
        }
        
        // Perform the actual HTTP request and receive data here.
        let content = try networkRequest(requestURL)
        
        // Try to parse content as SearchResult.
        let parsed = try parse(content, basedOn: previous)
        
        // Return successfully parsed content as SearchResult.
        return parsed
    }
    
    /// Download details for a certain SearchResultItem.
    /// - Parameter item: the item to get details about
    /// - Throws: NetworkError or Error if something goes wrong
    /// - Returns: an OMDBItem containing all details
    public func detailsFor(item: SearchResultItem) throws -> OMDBItem {
        
        guard let url = detailURL(with: item.imdbID) else {
            // TODO: add error handling
            throw NetworkError.failure("Unable to build URL for item with imdbID `\(item.imdbID)`.")
        }
        
        // Perform network request
        let content = try networkRequest(url)
        
        // Parse content to get an OMDBItem.
        let result = try parse(content)
        
        // Return item
        return result
    }
    
    // MARK: - Private functions
    
    /// Turns a JSON into a SearchResult.
    /// - Parameters:
    ///   - content: search response as a JSON as bytes, assuming utf8 encoding
    ///   - previous: a previous search result to add new result items to
    /// - Throws: NetworkError if parsing fails
    /// - Returns: a valid SearchResult if possible
    private func parse(_ content: Data, basedOn previous: SearchResult?) throws -> SearchResult {
        
        // Create a JSONDecoder.
        // Use this handle to adjust config.
        let decoder = JSONDecoder()
        
        // Try to turn the content into a SearchResult.
        if let result = try? decoder.decode(SearchResult.self, from: content) {
            
            // Successfully parsed response to a SearchResult!
            // Now append the search results from previous searches
            // and return the combined result object.
            return result.append(search: previous?.search)
        }
        else {
            
            // Failure: the result does not contain a SearchResult.
            // Set a default error message.
            var dialogText = "The request could not be satisfied."
            
            // Try to get a more detailed error message from the actual response.
            if let dict = try? JSONDecoder().decode([String: String].self, from: content),
               let message = dict["Error"]
            {
                dialogText += " (\(message))"
            }
            
            // Throw error with message.
            throw NetworkError.failure(dialogText)
        }
    }
    
    /// Turns a JSON into an OMDBItem.
    /// - Parameter content: response of a request by id as JSON bytes, assuming utf8 encoding
    /// - Throws: Error if parsing fails
    /// - Returns: a valid OMDBItem containing all infos from the content
    private func parse(_ content: Data) throws -> OMDBItem {
        
        // Create a JSONDecoder.
        // Use this handle to adjust config.
        let decoder = JSONDecoder()
        
        // Try to turn content into OMDBItem.
        // This might also throw with an error message.
        let result = try decoder.decode(OMDBItem.self, from: content)
        
        // Return result.
        return result
    }
    
    // MARK: - Private Functions
    
    /// Perform a HTTP GET request using URLSession.
    /// - Parameter url: the url to query
    /// - Throws: NetworkError with a message
    /// - Returns: content of response as bytes
    private func networkRequest(_ url: URL) throws -> Data {
        
        // Define a var that contains an eventual
        // result of the async http request.
        var content: Data?
        var errorMessage: String?
        
        // Create a semaphore to block the current thread later.
        let semaphore = DispatchSemaphore(value: 0)
        
        // Going onto another side thread for the network request.
        // This keeps the current thread usable.
        DispatchQueue.global().async {
            
            // Build the download task and handle the response.
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let error = error {
                    errorMessage = error.localizedDescription
                }
                else if let data = data {
                    content = data
                }
                
                // Release the semaphore.
                semaphore.signal()
            }
            
            // Kick off the task.
            task.resume()
        }
        
        // Make the current thread wait for the semaphore to be released.
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        if let content = content {
            // Return content if there is content.
            return content
        }
        else if let errorMessage = errorMessage {
            // Throw with error message if there is one.
            throw NetworkError.failure(errorMessage)
        }
        else {
            // Throw with "IDK"-error message.
            throw NetworkError.failure("An unknown error occurred while performing a GET request.")
        }
    }
    
    /// Creates an URL object for the use case: "fetching details".
    /// - Parameter imdbID: id of the object to get details for
    /// - Returns: URL for downloading details for an imdb id
    private func detailURL(with imdbID: String) -> URL? {
        
        // URL encode the value to be used in the HTTP request.
        guard let urlEncodedValue = imdbID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            // Early exit if encoding fails for whatever reason.
            return nil
        }
        
        // Build url string.
        let stringValue = String(format: RequestKind.byID.rawValue,
                                 urlEncodedValue,
                                 key)
        
        return URL(string: stringValue)
    }
    
    /// Creates an URL object for the use case: "search for term"
    /// - Parameters:
    ///   - term: the keyword/s to search for
    ///   - page: page number to request
    /// - Returns: URL for searching items
    private func searchURL(with term: String, page: Int) -> URL? {
        
        // URL encode the value to be used in the HTTP request.
        guard let urlEncodedValue = term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            // Early exit if encoding fails for whatever reason.
            return nil
        }
        
        // Build url string.
        let stringValue = String(format: RequestKind.search.rawValue, // <- The enum contains the format.
                                 urlEncodedValue,       // <- First arg is the encoded value.
                                 key,                   // <- Second arg is the api key.
                                 page)                  // <- Third arg is the page number, def. 1.
        
        // Return the string value as an URL object.
        // This will fall back to nil if cast fails.
        return URL(string: stringValue)
    }
}
