//
//  PosterURLFactory.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import Foundation

enum PosterURLFactory {
    private static var imageWidth: CGFloat { 185 } // Ideally we would get this value from https://developer.themoviedb.org/reference/configuration-details and choose the most appropriate size. Due to time limitations, I've chosen this size since it's the most appropriate for the created ui.
    private static var posterBaseURL: URL { Configuration.posterBaseUrl }

    static func generatePosterUrl(forPosterPath path: String?) -> URL? {
        guard let path
        else { return nil }

        let posterPath = "w\(Int(imageWidth))\(path)"
        if #available(iOS 16.0, *) {
            var imageUrl = posterBaseURL
            imageUrl.append(path: posterPath)
            return imageUrl
        } else {
            return posterBaseURL.appendingPathComponent(posterPath)
        }
    }
}
