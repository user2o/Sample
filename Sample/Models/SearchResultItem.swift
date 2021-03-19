//
//  SearchResultItem.swift
//  SimpleExample
//
//  Created by user2o on 07.03.21.
//

import Foundation

struct SearchResultItem: Codable, Identifiable {
    
    enum CodingKeys: String, CodingKey {
        case title = "Title", year = "Year", imdbID, type = "Type", poster = "Poster"
    }
    
    let id = UUID()
    let title, year, imdbID, type, poster: String
}

let testSearchResultItem = SearchResultItem(title: "Batman v Superman: Dawn of Justice",
                                            year: "2016",
                                            imdbID: "tt2975590",
                                            type: "movie",
                                            poster: "https://m.media-amazon.com/images/M/MV5BYThjYzcyYzItNTVjNy00NDk0LTgwMWQtYjMwNmNlNWJhMzMyXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg")
