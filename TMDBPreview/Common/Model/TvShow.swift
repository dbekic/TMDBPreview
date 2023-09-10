//
//  TvShow.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation

struct TvShow: Decodable {
    let id: Int
    let name: String
    let posterPath: String?
    let voteAverage: Double
}

struct TvShowDetails: Decodable {
    let lastAirDate: Date
    let lastEpisodeName: String

    enum CodingKeys: String, CodingKey {
        case lastAirDate
        case lastEpisodeToAir
    }

    enum AdditionalInfoKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lastAirDate = try values.decode(Date.self, forKey: .lastAirDate)

        let lastEpisodeToAir = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .lastEpisodeToAir)
        lastEpisodeName = try lastEpisodeToAir.decode(String.self, forKey: .name)
    }
}

struct TvShowItem {
    let tvShow: TvShow
    let details: TvShowDetails
}

extension TvShowItem: ContentCollectionItemTransformable {}
