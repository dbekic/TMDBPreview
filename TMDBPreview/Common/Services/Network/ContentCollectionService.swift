//
//  ContentCollectionService.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation
import RxSwift

protocol ContentCollectionService {
    associatedtype Item: ContentCollectionItemTransformable

    func getGenres() -> Single<[Genre]>
    func getItems(forGenreId genreId: Int, page: Int) -> Single<[Item]>
}

final class MoviesService: ContentCollectionService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }

    func getGenres() -> Single<[Genre]> {
        let genresResponse: Single<GenresResponse> = networkService.request(for: .movieGenres)

        return genresResponse
            .map { $0.genres }
    }

    func getItems(forGenreId genreId: Int, page: Int) -> Single<[MovieItem]> {
        let moviesResponse: Single<PageResponse<Movie>> = networkService.request(
            for: .movies(genreId: genreId, page: page)
        )

        return moviesResponse
            .map { $0.results }
            .flatMap { [networkService] movies in
                Single.zip(
                    movies.map { movie -> Single<MovieItem> in
                        let request: Single<MovieDetails> = networkService.request(for: .movieDetails(movieId: movie.id))

                        return request.map { MovieItem(movie: movie, details: $0) }
                    }
                )
            }
    }
}
final class TvShowsService: ContentCollectionService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }

    func getGenres() -> Single<[Genre]> {
        let genresResponse: Single<GenresResponse> = networkService.request(for: .tvShowGenres)

        return genresResponse
            .map { $0.genres }
    }

    func getItems(forGenreId genreId: Int, page: Int) -> Single<[TvShowItem]> {
        let tvShowsResponse: Single<PageResponse<TvShow>> = networkService.request(
            for: .tvShows(genreId: genreId, page: page)
        )

        return tvShowsResponse
            .map { $0.results }
            .flatMap { [networkService] tvShows in
                Single.zip(
                    tvShows.map { tvShow -> Single<TvShowItem> in
                        let request: Single<TvShowDetails> = networkService.request(for: .tvShowDetails(tvShowId: tvShow.id))

                        return request.map { TvShowItem(tvShow: tvShow, details: $0) }
                    }
                )
            }
    }
}
