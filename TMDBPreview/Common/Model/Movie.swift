//
//  Movie.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
}

struct MovieDetails: Decodable {
    let budget: Int
    let revenue: Int
}

struct MovieItem {
    let movie: Movie
    let details: MovieDetails
}

extension MovieItem: ContentCollectionItemTransformable {}
