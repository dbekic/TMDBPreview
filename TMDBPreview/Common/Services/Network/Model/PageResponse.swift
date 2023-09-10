//
//  PageResponse.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation

struct PageResponse<Item: Decodable>: Decodable {
    let page: Int
    let results: [Item]
    let totalPages: Int
    let totalResults: Int
}
