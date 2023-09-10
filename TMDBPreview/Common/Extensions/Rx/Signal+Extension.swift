//
//  Signal+Extension.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType where SharingStrategy == SignalSharingStrategy {
    func asInfallibleOnErrorComplete() -> Infallible<Element> {
        asInfallible(onErrorFallbackTo: .empty())
    }

    func asDriverOnErrorComplete() -> Driver<Element> {
        asDriver(onErrorDriveWith: .empty())
    }

    func compactMap<T>() -> Signal<T> where Element == T? {
        compactMap { $0 }
    }

    func mapTo<T>(_ value: T) -> Signal<T> {
        map { _ in value }
    }

    func mapToVoid() -> Signal<Void> {
        mapTo(())
    }

    func mapToOptional() -> Signal<Element?> {
        map { $0 as Element? }
    }
}
