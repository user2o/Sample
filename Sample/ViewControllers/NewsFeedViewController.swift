//
//  NewsFeedViewController.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit
import Nuke

class NewsFeedViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // Make sure to keep a strong reference to preheater.
    private let preheater = ImagePreheater()
    
    // Hold news in memory for displaying.
    private var news: [News] = [] {
        didSet {
            
            // Turn all image urls into ImageRequest objects.
            // This way the image can be modified, like applying filters.
            let requests = news.compactMap { imageRequest(url: $0.imageURL) }
            
            // Make sure to keep a strong reference to preheater.
            preheater.startPreheating(with: requests)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "NewsFeedCell", bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: "NewsFeedCell")
        
        updateNewsFeed()
    }
    
    // MARK: -
    
    /// Invokes the download of news items async.
    /// Also invokes updating the table view once finished.
    /// Also invokes showing an error message if something goes wrong.
    func updateNewsFeed() {
        
        DispatchQueue.global().async {
            
            // Creates the connector.
            let feed = NewsFeedConnector()
            
            do {
                // Calling the download and parse function.
                let news = try feed.fetch()
                
                DispatchQueue.main.async {
                    // Updating the UI once news were received.
                    self.updateNewsFeedFinished(news)
                }
            }
            catch NewsError.failure(let error) {
                // Show error message.
                let message = String(format: "Unfortnuately there was an error while getting the latest news: %@.", error)
                UIAlertController.simpleDialog(title: "Feed Error",
                                               message: message,
                                               button: "Close")
            }
            catch {
                // Show error message.
                let message = String(format: "Unfortnuately there was an error while getting the latest news: %@.", error.localizedDescription)
                UIAlertController.simpleDialog(title: "Feed Error",
                                               message: message,
                                               button: "Close")
            }
        }
    }
    
    /// Stores the result in a class property and invokes reloading the
    /// table view to present the news items.
    /// - Parameter result: a list of news items to present to the user
    func updateNewsFeedFinished(_ result: [News]) {
        news = result
        tableView.reloadData()
    }
    
    /// Create a ImageRequest for nuke from an image URL.
    ///
    /// - Parameters:
    ///   - url: image address
    /// - Returns: nil if url is not available, a simple unmodified ImageRequest otherwise
    func imageRequest(url: URL?) -> ImageRequest? {
        guard let url = url else { return nil }
        return ImageRequest(url: url)
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row \(indexPath.row)")
    }
}

extension NewsFeedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Dequeue the news cell from tableview.
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath)
        
        // Try to cast it.
        if let cell = cell as? NewsFeedCell {
            
            // Assign current news to current cell.
            let current = news[indexPath.row]
            cell.news = current
            
            // Using Nuke to download current header image into cell.
            if let request = imageRequest(url: current.imageURL) {
                
                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "Placeholder"),
                    transition: .fadeIn(duration: 0.125)
                )
                
                Nuke.loadImage(with: request,
                               options: options,
                               into: cell.headImageView)
            }
            else {
                // Set fallback image
                cell.headImageView.image = UIImage(named: "Placeholder")
            }
        }
        
        return cell
    }
}
