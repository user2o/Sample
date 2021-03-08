//
//  SearchResultItem.swift
//  SimpleExample
//
//  Created by user2o on 07.03.21.
//

import Foundation

struct SearchResultItem: Codable {
    
    enum CodingKeys: String, CodingKey {
        case title = "Title", year = "Year", imdbID, type = "Type", poster = "Poster"
    }
    let title, year, imdbID, type, poster: String
}
