//
//  LookupDetailKeyValueCell.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class LookupDetailKeyValueCell: UITableViewCell {

    @IBOutlet weak var labelKey: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelKey.text     = ""
        labelValue.text   = ""
    }
    
}
