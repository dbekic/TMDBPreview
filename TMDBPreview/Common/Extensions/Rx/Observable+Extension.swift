//
//  Observable+Extension.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import RxSwift
import RxCocoa

extension ObservableType {
    func asDriverOnErrorComplete() -> Driver<Element> {
        asDriver(onErrorDriveWith: .empty())
    }

    func asSignalOnErrorComplete() -> Signal<Element> {
        asSignal(onErrorSignalWith: .empty())
    }

    func asInfallibleOnErrorComplete() -> Infallible<Element> {
        asInfallible(onErrorFallbackTo: .empty())
    }

    func mapToResult() -> Infallible<Result<Element, Error>> {
        map { element in
            .success(element)
        }
        .asInfallible { error in
            .just(.failure(error))
        }
    }
}
