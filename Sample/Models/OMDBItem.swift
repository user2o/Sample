//
//  OMDBItem.swift
//  SimpleExample
//
//  Created by user2o on 07.03.21.
//

import Foundation

struct OMDBItem: Codable {
    
    enum CodingKeys: String, CodingKey {
        case title = "Title",
             rated = "Rated",
             released = "Released",
             runtime = "Runtime",
             genre = "Genre",
             writer = "Writer",
             actors = "Actors",
             plot = "Plot",
             poster = "Poster"
        case imdbRating
    }
    
    let title, rated, released, runtime, genre, writer, actors, plot, poster, imdbRating: String
}
