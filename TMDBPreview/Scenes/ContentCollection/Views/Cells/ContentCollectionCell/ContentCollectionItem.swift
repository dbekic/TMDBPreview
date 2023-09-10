//
//  ContentCollectionItem.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import Foundation

struct ContentCollectionItem: Equatable, Identifiable, Hashable {
    let id = UUID()
    let posterUrl: URL?
    let title: String
    let rating: String
    let additionalInfo: String
}
