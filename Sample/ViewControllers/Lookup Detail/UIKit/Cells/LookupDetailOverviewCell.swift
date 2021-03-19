//
//  LookupDetailOverviewCell.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class LookupDetailOverviewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var ratedLabel: UILabel!
    
    var item: OMDBItem? {
        didSet {
            layout()
        }
    }
    
    func layout() {
        dateLabel.text      = item?.released ?? "N/A"
        runtimeLabel.text   = item?.runtime ?? "N/A"
        ratedLabel.text     = item?.rated ?? "N/A"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text      = ""
        runtimeLabel.text   = ""
        ratedLabel.text     = ""
    }
}
