//
//  NewsFeedViewController.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class NewsFeedViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    private var news: [News] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            catch NewsError.failure(let message) {
                // TODO: handle error
            }
            catch {
                // TODO: a more generic error
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
}
