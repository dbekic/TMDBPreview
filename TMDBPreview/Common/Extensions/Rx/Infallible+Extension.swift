//
//  Infallible+Extension.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import RxSwift
import RxCocoa

extension Infallible {
    func compactMap<T>() -> Infallible<T> where Element == T? {
        compactMap { $0 }
    }

    func mapTo<T>(_ value: T) -> Infallible<T> {
        map { _ in value }
    }

    func mapToVoid() -> Infallible<Void> {
        mapTo(())
    }

    func mapToOptional() -> Infallible<Element?> {
        map { $0 as Element? }
    }

    func shareLatest(scope: RxSwift.SubjectLifetimeScope = .whileConnected) -> Infallible<Element> {
        share(replay: 1, scope: scope)
    }

    func asDriverOnErrorComplete() -> Driver<Element> {
        asDriver(onErrorDriveWith: .empty())
    }

    func asSignalOnErrorComplete() -> Signal<Element> {
        asSignal(onErrorSignalWith: .empty())
    }
}
