//
//  GenreItem.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import Foundation

struct GenreItem: Equatable, Identifiable, Hashable {
    let id: Int
    let name: String
    let isSelected: Bool
}
