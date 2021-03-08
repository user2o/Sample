//
//  NewsFeedViewController.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit
import Nuke
import SafariServices

class NewsFeedViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    // Make sure to keep a strong reference to preheater.
    private let preheater = ImagePreheater()
    
    // Hold news in memory for displaying.
    private var news: [News] = [] {
        didSet {
            
            // Turn all image urls into ImageRequest objects.
            // This way the image can be modified, like applying filters.
            let requests = news.compactMap { imageRequest($0) }
            
            // Make sure to keep a strong reference to preheater.
            preheater.startPreheating(with: requests)
        }
    }
    
    // Temporary remember to reload the table when the feed URL changed.
    private var needsReload: Bool = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(feedURLChanged(note:)),
                                               name: .feedURLChanged,
                                               object: nil)
        
        setupTableView()
        updateNewsFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsReload {
            needsReload = false
            tableView.reloadData()
        }
    }
    
    /// Registers the required cells and applies further configuration.
    func setupTableView() {
        
        // Add refresh control.
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "pull to refresh")
        refresh.addTarget(self,
                          action: #selector(refreshValueChanged(sender:)),
                          for: .valueChanged)
        tableView.refreshControl = refresh
        
        // Register Nib as cell.
        let cellNib = UINib(nibName: "NewsFeedCell", bundle: Bundle.main)
        tableView.register(cellNib, forCellReuseIdentifier: "NewsFeedCell")
        
        // Activate self sizing cells.
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        
        // Add some insets
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    // MARK: - Refresh Control Action
    
    @objc func refreshValueChanged(sender: UIRefreshControl) {
        updateNewsFeed()
    }
    
    // MARK: -
    
    /// Invokes the download of news items on a side thread.
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
            catch NetworkError.failure(let error) {
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
            
            // End refresh control.
            DispatchQueue.main.asyncAfter(deadline: .now()+0.125) {
                self.tableView.refreshControl?.endRefreshing()
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
    func imageRequest(_ news: News) -> ImageRequest? {
        
        // Make sure there is an image URL.
        guard let url = news.imageURL else { return nil }
        
        // Determine if grayscale filter should be used.
        let useFilter = news.read && Settings.shared.rssGrayscaleReadArticles
        
        let processors: [ImageProcessors.CoreImageFilter]
        
        if useFilter {
            // Add CIFilter to list of processors.
            let monoFilter = ImageProcessors.CoreImageFilter(name: "CIPhotoEffectMono")
            processors = [monoFilter]
        }
        else {
            // Do not use filter at all. Just the plain image.
            processors = []
        }
        
        return ImageRequest(url: url, processors: processors)
    }
    
    // MARK: - Notification
    
    @objc func feedURLChanged(note: Notification) {
        news = []
        needsReload = true
        updateNewsFeed()
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let current = news[indexPath.row]
        
        guard let url = URL(string: current.link) else {
            UIAlertController.simpleDialog(message: "This news has no link.")
            return
        }
        
        let safariConfig = SFSafariViewController.Configuration()
        safariConfig.entersReaderIfAvailable = true
        
        let safariVC = SFSafariViewController(url: url,
                                              configuration: safariConfig)
        
        present(safariVC, animated: true) {
            
            current.setRead(true)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
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
            if let request = imageRequest(current) {
                
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
