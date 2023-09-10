//
//  Configuration.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey
        case invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

// swiftlint:disable force_try
// Disabling force_try here. We want the app to fail fast if configuration keys are not present
extension Configuration {
    static var apiBaseURL: URL {
        URL(string: "https://" + (try! Configuration.value(for: "API_BASE_URL")))!
    }

    static var apiKey: String {
        try! Configuration.value(for: "API_KEY")
    }

    static var apiReadAccessToken: String {
        try! Configuration.value(for: "API_READ_ACCESS_TOKEN")
    }

    static var posterBaseUrl: URL {
        URL(string: "https://" + (try! Configuration.value(for: "POSTER_BASE_URL")))!
    }
}
// swiftlint:enable force_try
