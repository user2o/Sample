//
//  SearchResultCell.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: - Properties
    
    var item: SearchResultItem? {
        didSet {
            layout()
        }
    }
    
    // MARK: - View Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        item = nil
    }
    
    func layout() {
        
        guard let item = item else {
            posterImageView.image = UIImage(named: "Placeholder")
            titleLabel.text = ""
            infoLabel.text = ""
            return
        }
        
        titleLabel.text = item.title
        infoLabel.text = String(format: "%@ · %@", item.type, item.year)
    }
    
}
