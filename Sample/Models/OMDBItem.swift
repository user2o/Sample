//
//  OMDBItem.swift
//  SimpleExample
//
//  Created by user2o on 07.03.21.
//

import Foundation

struct OMDBItem: Codable, Identifiable {
    
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
    
    let id = UUID()
    let title, rated, released, runtime, genre, writer, actors, plot, poster, imdbRating: String
}

let testOMDBItem = OMDBItem(title: "Superman Returns",
                            rated: "PG-13",
                            released: "28 Jun 2006",
                            runtime: "154 min",
                            genre: "Action, Sci-Fi",
                            writer: "Michael Dougherty (screenplay), Dan Harris (screenplay), Bryan Singer (story), Michael Dougherty (story), Dan Harris (story), Jerry Siegel (characters), Joe Shuster (characters)",
                            actors: "Brandon Routh, Kate Bosworth, Kevin Spacey, James Marsden",
                            plot: "Superman returns to Earth after spending five years in space examining his homeworld Krypton. But he finds things have changed while he was gone, and he must once again prove himself important to the world.",
                            poster: "https://m.media-amazon.com/images/M/MV5BNzY2ZDQ2MTctYzlhOC00MWJhLTgxMmItMDgzNDQwMDdhOWI2XkEyXkFqcGdeQXVyNjc1NTYyMjg@._V1_SX300.jpg",
                            imdbRating: "6.0")
