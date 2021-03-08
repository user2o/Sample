//
//  LookupDetailRatingCell.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class LookupDetailRatingCell: UITableViewCell {

    @IBOutlet weak var ratingLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ratingLabel.text = ""
    }
}
