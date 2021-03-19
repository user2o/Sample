//
//  LookupViewController.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit
import Nuke
import SwiftUI

class LookupViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    private var searchActive    : Bool          = false
    private var searchTerm      : String        = ""
    private var lastResult      : SearchResult? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        searchBar.becomeFirstResponder()
    }
    
    /// Registers the required cells and applies further configuration.
    private func setupTableView() {
        
        // Register Nib as cell.
        let resultCellNib = UINib(nibName: "SearchResultCell", bundle: Bundle.main)
        tableView.register(resultCellNib, forCellReuseIdentifier: "SearchResultCell")
        
        // Activate self sizing cells.
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        
        // Add some insets
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    // MARK: -
    
    /// Used when starting a whole new search. This function will also
    /// clear the currently known results and empty the table. It will then
    /// start the request to search for the term.
    /// - Parameter term: the string to search for
    private func startSearch(_ term: String) {
        
        if searchActive { return }
        
        // Reset UI
        lastResult = nil
        tableView.reloadData()
        
        // Remember the current text as search term.
        searchTerm = term
        
        // ...
        requestData()
    }
    
    /// Can be called once to get the next chunk of data from the api.
    /// The new data will contain the old data, it will therefore replace
    /// the current content of the variable lastResult.
    private func requestData() {
        
        // Set request blocking flag to true.
        searchActive = true
        
        // Make sure there are more items to download.
        if let last = lastResult,
           !last.moreAvailable
        {
            print("no more data available")
            searchActive = false
            return
        }
        
        // Start request on background thread.
        DispatchQueue.global().async {
            
            do {
                // Perform search request
                let result = try OMDBConnector().search(title: self.searchTerm,
                                                        basedOn: self.lastResult)
                
                DispatchQueue.main.async {
                    self.handleNewData(result)
                }
            }
            catch NetworkError.failure(let message) {
                
                UIAlertController.simpleDialog(message: "Something went wrong while trying to access the lookup feature: \(message).")
            }
            catch {
                
                UIAlertController.simpleDialog(message: "Something went wrong while trying to access the lookup feature: \(error.localizedDescription).")
            }
            
            // Release the blocking flag.
            self.searchActive = false
        }
    }
    
    /// Invokes the SwiftUI detail view.
    /// - Parameter item: the search result item to be resolved at the omdb api
    private func showSwiftUI(_ item: SearchResultItem?) {
        
        guard let item = item else {
            // TODO: show error alert
            return
        }
        
        // Create the resolver. It immediately starts resolving the item.
        let resolver = OMDBResolver(searchResult: item)
        
        // Create the detail view written in SwiftUI.
        let swiftUIController = LookupDetailSwiftUI(resolver: resolver)
        
        // Instantiate the UIKit container to hold the SwiftUI controller.
        // And present it modally.
        let detailViewController = UIHostingController(rootView: swiftUIController)
        detailViewController.modalPresentationStyle = .formSheet
        present(detailViewController, animated: true, completion: nil)
    }
    
    /// Updates the UI with the latest search result.
    /// - Parameter newData: new SearchResult to show in the UI; this will replace the current lastResult class property
    private func handleNewData(_ newData: SearchResult) {
        
        // Count number of items before new data arrived.
        let oldCount = self.lastResult?.search.count ?? 0
        
        // Count number of items including new data.
        let sumCount = newData.search.count
        
        // Remember current result.
        self.lastResult = newData
        
        // Update TableView on main thread.
        DispatchQueue.main.async {
            
            self.tableView.performBatchUpdates({
                
                // Make list of new IndexPath objects.
                let newPaths = (oldCount..<sumCount).map {
                    IndexPath(item: $0, section: 0)
                }
                
                // Insert paths into table view.
                self.tableView.insertRows(at: newPaths, with: .automatic)
                
            }, completion: nil)
            
            // Release request blocking flag.
            self.searchActive = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? LookupDetailViewController,
           let sender = sender as? SearchResultItem
        {
            destination.searchResult = sender
        }
    }
}

extension LookupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selected = lastResult?.search[indexPath.row]
        
        let s = Settings.shared
        switch s.useSwiftUIDetailView {
            case true:
                showSwiftUI(selected)
            case false:
                performSegue(withIdentifier: "LookupDetail", sender: selected)
        }
    }
}

extension LookupViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastResult?.search.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        
        if let cell = cell as? SearchResultCell,
           let item = lastResult?.search[indexPath.row]
        {
            cell.item = item
            
            if let url = URL(string: item.poster) {
                
                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "Placeholder"),
                    transition: .fadeIn(duration: 0.125)
                )
                
                Nuke.loadImage(with: url,
                               options: options,
                               into: cell.posterImageView)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let items = lastResult?.search.count ?? 1
        
        if (indexPath.row == items-1 ) {
            requestData()
        }
    }
}

extension LookupViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // print("did end")
        
        // Fetch text from searchbar
        guard let text = searchBar.text else { return }
        
        // Make sure the text isnt an empty string.
        guard !text.isEmpty else { return }
        
        // Make sure the text is different from the current search.
        guard text != searchTerm else { return }
        
        startSearch(text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("did click search button")
        searchBar.resignFirstResponder()
    }
}
