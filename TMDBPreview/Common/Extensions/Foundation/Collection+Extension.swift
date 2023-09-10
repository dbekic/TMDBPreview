//
//  Collection+Extension.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
