//
//  NetworkService.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation
import RxCocoa
import RxSwift

final class NetworkService {
    private let urlSession = URLSession.shared
    private lazy var decoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(Self.dateFormatter)
        return decoder
    }()

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    func request<T: Decodable>(
        for endpoint: Endpoint
    ) -> Single<T> {
        urlSession.rx
            .data(request: endpoint.urlRequest)
            .map { [decoder] data in
                try decoder.decode(T.self, from: data)
            }
            .asSingle()
    }
}
