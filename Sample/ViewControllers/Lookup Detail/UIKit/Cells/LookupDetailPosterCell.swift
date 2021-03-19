//
//  LookupDetailPosterCell.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class LookupDetailPosterCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }
}
