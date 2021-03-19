//
//  SettingsTableViewController.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit
import Just

class SettingsTableViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var switchGrayscale  : UISwitch!
    @IBOutlet weak var textFieldFeedURL : UITextField!
    @IBOutlet weak var textFieldAPIKey  : UITextField!
    @IBOutlet weak var switchSwiftUI: UISwitch!
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup() {
        
        let s                   = Settings.shared
        switchGrayscale.isOn    = s.rssGrayscaleReadArticles
        textFieldFeedURL.text   = s.rssFeedURL.absoluteString
        textFieldAPIKey.text    = s.apiKey
        switchSwiftUI.isOn      = s.useSwiftUIDetailView
    }
    
    // MARK: - Actions
    
    @IBAction func switchGrayscaleValueChanged(_ sender: Any) {
        
        guard let sender = sender as? UISwitch else {
            setup()
            return
        }
        
        let s = Settings(grayscale: sender.isOn)
        _ = s.store()
    }
    
    @IBAction func switchUswSwiftUIValueChanged(_ sender: Any) {
        
        guard let sender = sender as? UISwitch else {
            setup()
            return
        }
        
        let s = Settings(swiftUI: sender.isOn)
        _ = s.store()
    }
    // MARK: -
    
    func block() -> UIAlertController {
        
        let controller = UIAlertController(title: "Reaching Out",
                                           message: "\n\n\nTesting feed url. Please wait.",
                                           preferredStyle: .alert)
        
        let activityIndicator = UIActivityIndicatorView(frame: controller.view.bounds)
        activityIndicator.style = .medium
        activityIndicator.startAnimating()
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        controller.view.addSubview(activityIndicator)
        controller.prompt()
        
        return controller
    }
    
    func textFieldFeedURLValueChanged(_ value: String?) {
        
        // Block the screen for evaluation of the input.
        let blocker = block()
        
        // Fetch the text from the textfield.
        // Also remove white spaces and new lines.
        let feedCandidateURL = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Make sure the input is a valid URL.
        guard let url = URL(string: feedCandidateURL) else {
            
            // Unblock and show error alert.
            blocker.dismiss(animated: true) {
                UIAlertController.simpleDialog(message: "Unable to turn the input into an URL. Please retype the URL and try again.")
            }
            
            // Reset text to settings value.
            textFieldFeedURL.text = Settings.shared.rssFeedURL.absoluteString
            
            return
        }
        
        // Download head as availability check.
        let just = JustOf<HTTP>()
        let response = just.head(url)
        
        // Exit function if website is not available.
        guard response.ok else {
            
            // Unblock and show error alert.
            blocker.dismiss(animated: true) {
                UIAlertController.simpleDialog(message: "Unable to reach the website so I can't accept it as input right now.")
            }
            
            // Do not reset textfield text property.
            // User can now correct the text, maybe she mistyped the url?
            
            return
        }
        
        // Save new URL as default.
        let modified = Settings(feedURL: url)
        if modified.store() {
            
            // Notify all observers to update.
            NotificationCenter.default.post(name: .feedURLChanged,
                                            object: nil)
            
            
            blocker.dismiss(animated: true, completion: nil)
        }
        else {
            // show alert
            blocker.dismiss(animated: true) {
                UIAlertController.simpleDialog(message: "Unable to store changed settings. This is bad.")
            }
        }
    }
    
    func textFieldAPIKeyValueChanged(_ value: String?) {
        
        // Fetch the text from the textfield.
        // Also remove white spaces and new lines.
        let newAPIKey = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Exit here if text is empty
        guard !newAPIKey.isEmpty else {
            UIAlertController.simpleDialog(message: "An empty key is not working. Please obtain your api key from https://omdbapi.com and type it here.")
            return
        }
        
        // Save new API key as default.
        let modified = Settings(apiKey: newAPIKey)
        _ = modified.store()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0: return 2
            case 1: return 2
            default: return 0
        }
    }

}

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Close keyboard right away
        textField.resignFirstResponder()
        
        switch textField {
            case self.textFieldFeedURL:
                self.textFieldFeedURLValueChanged(textField.text)
                
            case self.textFieldAPIKey:
                self.textFieldAPIKeyValueChanged(textField.text)
                
            default:
                print("o.O")
        }
        
        return true
    }
}
