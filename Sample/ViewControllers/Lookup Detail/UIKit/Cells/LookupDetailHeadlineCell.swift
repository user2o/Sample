//
//  LookupDetailHeadlineCell.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class LookupDetailHeadlineCell: UITableViewCell {
    
    @IBOutlet weak var headlineLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        headlineLabel.text = ""
    }
    
}
