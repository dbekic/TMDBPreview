//
//  Driver+Extension.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    func compactMap<T>() -> Driver<T> where Element == T? {
        return compactMap { $0 }
    }

    func mapTo<T>(_ value: T) -> Driver<T> {
        return map { _ in value }
    }

    func mapToVoid() -> Driver<Void> {
        return mapTo(())
    }

    func mapToOptional() -> Driver<Element?> {
        map { $0 as Element? }
    }

    func asSignalOnErrorComplete() -> Signal<Element> {
        asSignal(onErrorSignalWith: .empty())
    }
}
