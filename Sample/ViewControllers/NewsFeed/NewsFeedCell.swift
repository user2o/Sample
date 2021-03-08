//
//  NewsFeedCell.swift
//  Sample
//
//  Created by user2o on 08.03.21.
//

import UIKit

class NewsFeedCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var headImageView    : UIImageView!
    @IBOutlet weak var headlineLabel    : UILabel!
    @IBOutlet weak var bodyLabel        : UILabel!
    @IBOutlet weak var dateLabel        : UILabel!
    
    // MARK: - Properties
    
    var news: News? {
        didSet { layout() }
    }
    
    // MARK: -
    
    func layout() {
        
        guard let news = news else {
            headImageView.image = nil
            headlineLabel.text  = ""
            dateLabel.text      = ""
            bodyLabel.text      = ""
            return
        }
        
        headlineLabel.text      = news.title
        bodyLabel.text          = news.description
        dateLabel.text          = news.publishedFormatted
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        news = nil
    }
}
