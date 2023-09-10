//
//  Result+Extension.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import Foundation

extension Result {
    var value: Success? {
        switch self {
        case let .success(value): return value
        case .failure: return nil
        }
    }

    var error: Failure? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }
}
