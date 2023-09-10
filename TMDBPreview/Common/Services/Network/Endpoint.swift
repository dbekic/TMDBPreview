//
//  Endpoint.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation

protocol URLRequestConvertible {
    var urlRequest: URLRequest { get }
}

enum Endpoint {
    case movieGenres
    case tvShowGenres
    case movies(genreId: Int, page: Int)
    case tvShows(genreId: Int, page: Int)
    case movieDetails(movieId: Int)
    case tvShowDetails(tvShowId: Int)
}

// MARK: - API Specific data
private extension Endpoint {
    var baseUrl: URL {
        Configuration.apiBaseURL
    }

    var apiVersion: Int {
        3
    }

    var headers: [String: String] {
        [
          "accept": "application/json",
          "Authorization": "Bearer \(Configuration.apiReadAccessToken)"
        ]
    }

    var path: String {
        switch self {
        case .movieGenres:
            return "genre/movie/list"
        case .tvShowGenres:
            return "genre/tv/list"
        case .movies:
            return "discover/movie"
        case .tvShows:
            return "discover/tv"
        case let .movieDetails(movieId: id):
            return "movie/\(id)"
        case let .tvShowDetails(tvShowId: id):
            return "tv/\(id)"
        }
    }
}

// MARK: - URLRequestConvertible conformance
extension Endpoint: URLRequestConvertible {
    private var requestURL: URL {
        if #available(iOS 16.0, *) {
            var requestURL = baseUrl
            requestURL.append(path: "\(apiVersion)")
            requestURL.append(path: path)
            return requestURL.appending(queryItems: queryItems)
        } else {
            let query = queryItems
                .map { item in
                    guard let value = item.value
                    else { return "\(item.name)" }

                    return "\(item.name)=\(value)"
                }
                .joined(separator: "&")

            let endpointString = baseUrl
                .appendingPathComponent("\(apiVersion)")
                .appendingPathComponent(path)
                .absoluteString

            guard let endpoint = URL(string: endpointString + "?\(query)")
            else { fatalError("Unable to create request URL") } // We want to fail fast here as well, although the url should always be generated. There are better ways to handle the failure such as throwing errors but due to time limitations, I've chosen not to propagate it.

            return endpoint
        }
    }

    private var queryItems: [URLQueryItem] {
        var queryItems = [URLQueryItem(name: "language", value: "en")] // Also hardcoded for the purposes of this task

        switch self {
        case let .movies(genreId: genreId, page: page):
            queryItems.append(.init(name: "page", value: "\(page)"))
            queryItems.append(.init(name: "sort_by", value: "popularity.desc"))
            queryItems.append(.init(name: "include_adult", value: "false"))
            queryItems.append(.init(name: "include_video", value: "false"))
            queryItems.append(.init(name: "with_genres", value: "\(genreId)"))
        case let .tvShows(genreId: genreId, page: page):
            queryItems.append(.init(name: "page", value: "\(page)"))
            queryItems.append(.init(name: "sort_by", value: "popularity.desc"))
            queryItems.append(.init(name: "include_adult", value: "false"))
            queryItems.append(.init(name: "include_null_first_air_dates", value: "false"))
            queryItems.append(.init(name: "with_genres", value: "\(genreId)"))
        default:
            break
        }

        return queryItems
    }

    var urlRequest: URLRequest {
        var request = URLRequest(
            url: requestURL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )

        request.httpMethod = "GET" // Hardcoded for the needs of this projects
        request.allHTTPHeaderFields = headers

        return request
    }
}
