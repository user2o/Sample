//
//  Poster.swift
//  Sample
//
//  Created by user2o on 19.03.21.
//

import SwiftUI
import Just

/// A SwiftUI observable that will resolve an URL to an image.
/// If resolving fails, nothing happens. If resolving suceeds the
/// published image is set and so updates the observing UI automatically.
class Poster: ObservableObject {
    
    /// The resolved image.
    /// Is set async when the download has completed.
    @Published var image: UIImage = UIImage(systemName: "photo")!
    
    /// Immediately starts downloading from the URL.
    /// - Parameter url: an url to download an image from
    init(url: String) {
        // Going async to keep current thread working.
        DispatchQueue.global().async {
            self.download(url)
        }
    }
    
    /// Uses `Just` to request data from the passed in URL.
    /// Sets the `image` variable on the main thread when download succeeded.
    /// Does nothing when download failes.
    /// - Parameter url: the url pointing to an image resource
    func download(_ url: String) {
        
        // Init. local instance of just.
        let just = JustOf<HTTP>()
        
        // Perform get request with url.
        let response = just.get(url)
        
        // Make sure the response contains bytes which
        // can be used as image.
        guard let content = response.content else { return }
        guard let image = UIImage(data: content) else { return }
        
        DispatchQueue.main.async {
            // Set @Published image which invokes UI update.
            self.image = image
        }
    }
}
