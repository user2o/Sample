//
//  LookupDetailViewController.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit
import Nuke

class LookupDetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let ROW_COUNT       = 8
    private let INDEX_TITLE     = 0
    private let INDEX_POSTER    = 1
    private let INDEX_OVERVIEW  = 2
    private let INDEX_PLOT      = 3
    private let INDEX_GENRE     = 4
    private let INDEX_WRITER    = 5
    private let INDEX_ACTORS    = 6
    private let INDEX_RATING    = 7
    
    var searchResult: SearchResultItem!
    private var omdbItem: OMDBItem?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure that a searchResult has been set.
        guard searchResult != nil else {
            
            // Early exit when search result is not set.
            // Dismiss modal view controller and show dialog.
            dismiss(animated: true) {
                
                UIAlertController.simpleDialog(message: "Unable to display the selected item.")
            }
            
            return
        }
        
        setupTableView()
        fillTableWithData()
    }
    
    /// Registers the required cells and applies further configuration.
    private func setupTableView() {
        
        let headlineNib = UINib(nibName: "LookupDetailHeadlineCell", bundle: Bundle.main)
        tableView.register(headlineNib, forCellReuseIdentifier: "LookupDetailHeadlineCell")
        
        let posterNib = UINib(nibName: "LookupDetailPosterCell", bundle: Bundle.main)
        tableView.register(posterNib, forCellReuseIdentifier: "LookupDetailPosterCell")
        
        let overviewNib = UINib(nibName: "LookupDetailOverviewCell", bundle: Bundle.main)
        tableView.register(overviewNib, forCellReuseIdentifier: "LookupDetailOverviewCell")
        
        let keyValueNib = UINib(nibName: "LookupDetailKeyValueCell", bundle: Bundle.main)
        tableView.register(keyValueNib, forCellReuseIdentifier: "LookupDetailKeyValueCell")
        
        let ratingNib = UINib(nibName: "LookupDetailRatingCell", bundle: Bundle.main)
        tableView.register(ratingNib, forCellReuseIdentifier: "LookupDetailRatingCell")
    }
    
    /// Invokes downloading details for the SearchResultItem.
    /// The result will be stored in the class property `omdbItem`.
    private func fillTableWithData() {
        
        // Using a side thread to avoid blocking the main thread.
        DispatchQueue.global().async {
            
            do {
                // Download details for searchResult.
                let details = try OMDBConnector().detailsFor(item: self.searchResult)
                
                DispatchQueue.main.async {
                    // Remember details result for further usage.
                    self.omdbItem = details
                    
                    // Reload tableView to show content.
                    self.tableView.reloadData()
                }
            }
            catch {
                
                // Dismiss controller and show error message
                // when download fails for whatever reason.
                self.dismiss(animated: true) {
                    UIAlertController.simpleDialog(message: "Unable to display the selected item.")
                }
            }
        }
    }
    
    private func cellIdentifierFor(indexPath: IndexPath) -> String {
        
        switch indexPath.row {
            case INDEX_TITLE:
                return "LookupDetailHeadlineCell"
            case INDEX_POSTER:
                return "LookupDetailPosterCell"
            case INDEX_OVERVIEW:
                return "LookupDetailOverviewCell"
            case INDEX_GENRE, INDEX_WRITER, INDEX_ACTORS, INDEX_PLOT:
                return "LookupDetailKeyValueCell"
            case INDEX_RATING:
                return "LookupDetailRatingCell"
            default:
                return ""
        }
    }
}

extension LookupDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row \(indexPath.row)")
    }
}

extension LookupDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ROW_COUNT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = cellIdentifierFor(indexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let cell = cell as? LookupDetailHeadlineCell {
            
            cell.headlineLabel.text = omdbItem?.title ?? "N/A"
        }
        else if let cell = cell as? LookupDetailPosterCell {
            
            if let address = omdbItem?.poster,
               let url = URL(string: address)
            {
                Nuke.loadImage(with: url,
                               into: cell.posterImageView)
            }
        }
        else if let cell = cell as? LookupDetailOverviewCell {
            
            cell.item = omdbItem
        }
        else if let cell = cell as? LookupDetailKeyValueCell {
            
            switch indexPath.row {
                case INDEX_GENRE:
                    cell.labelKey.text = "GENRE"
                    cell.labelValue.text = omdbItem?.genre ?? "N/A"
                case INDEX_WRITER:
                    cell.labelKey.text = "WRITER"
                    cell.labelValue.text = omdbItem?.writer ?? "N/A"
                case INDEX_ACTORS:
                    cell.labelKey.text = "ACTORS"
                    cell.labelValue.text = omdbItem?.actors ?? "N/A"
                case INDEX_PLOT:
                    cell.labelKey.text = "PLOT"
                    cell.labelValue.text = omdbItem?.plot ?? "N/A"
                default:
                    cell.labelKey.text = "N/A"
                    cell.labelValue.text = omdbItem?.genre ?? "N/A"
            }
        }
        else if let cell = cell as? LookupDetailRatingCell {
            
            if let rating = omdbItem?.imdbRating {
                cell.ratingLabel.text = String(format: "⭐️ %@ / 10", rating)
            }
            else {
                cell.ratingLabel.text = "⭐️ N/A"
            }
        }
        
        return cell
    }
    
}
