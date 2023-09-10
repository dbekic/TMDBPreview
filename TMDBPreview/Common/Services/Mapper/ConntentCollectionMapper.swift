//
//  ContentCollectionMapper.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation

protocol ContentCollectionItemTransformable {}

protocol ContentCollectionMapper {
    associatedtype TransformableItem: ContentCollectionItemTransformable
    func transform(contentCollectionItemConvertibleItem item: TransformableItem) -> ContentCollectionItem
}

final class MovieMapper: ContentCollectionMapper {
    private static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()

    func transform(contentCollectionItemConvertibleItem item: MovieItem) -> ContentCollectionItem {
        let budget = Double(item.details.budget) / 10000000 as NSNumber // swiftlint:disable:this legacy_objc_type
        let budgetString = Self.numberFormatter.string(from: budget) ?? "\(0)"
        let revenue = Double(item.details.revenue) / 10000000 as NSNumber // swiftlint:disable:this legacy_objc_type
        let revenueString = Self.numberFormatter.string(from: revenue) ?? "\(0)"

        let additionalInfo = """
        Budget: \(budgetString)M
        Revenue: \(revenueString)M
        """

        return ContentCollectionItem(
            posterUrl: PosterURLFactory.generatePosterUrl(forPosterPath: item.movie.posterPath),
            title: "Title: \(item.movie.title)",
            rating: "Rating: \(item.movie.voteAverage)",
            additionalInfo: additionalInfo
        )
    }
}

final class TvShowMapper: ContentCollectionMapper {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        return dateFormatter
    }()

    func transform(contentCollectionItemConvertibleItem item: TvShowItem) -> ContentCollectionItem {
        let additionalInfo = """
        Last Air Date: \(Self.dateFormatter.string(from: item.details.lastAirDate))
        Last Episode: \(item.details.lastEpisodeName)
        """

        return ContentCollectionItem(
            posterUrl: PosterURLFactory.generatePosterUrl(forPosterPath: item.tvShow.posterPath),
            title: "Name: \(item.tvShow.name)",
            rating: "Rating: \(item.tvShow.voteAverage)",
            additionalInfo: additionalInfo
        )
    }
}
