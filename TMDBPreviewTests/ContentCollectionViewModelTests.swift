//
//  ContentCollectionViewModelTests.swift
//  TMDBPreviewTests
//
//  Created by Dejan Bekic on 10.9.23..
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import TMDBPreview

class ContentCollectionViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    func testThatErrorIsTrueWhenServiceFails() throws {
        let service = MoviesServiceMock()
        service.shouldThrowForGenres = true

        let viewModelFactory = ContentCollectionViewModel.viewModel(
            service: service,
            viewItemMapper: MovieMapper()
        )

        let output = viewModelFactory(
            .init(
                reload: .never(),
                nextPage: .never(),
                reloadOnError: .never(),
                selectedGenre: .never()
            )
        )

        let errorObserver = scheduler.createObserver(Bool.self)
        output
            .hasError
            .drive(errorObserver)
            .disposed(by: disposeBag)

        XCTAssertEqual(errorObserver.events, [.next(0, true)])
    }
}

// MARK: - Mocks
final class MoviesServiceMock: ContentCollectionService {
    enum MoviesServiceMockError: Error {
        case someServiceErrorCase
    }

    var shouldThrowForGenres = false
    var shouldThrowForItems = false
    let genresRelay = BehaviorRelay<[Genre]>(value: [])
    let itemsRelay = BehaviorRelay<[MovieItem]>(value: [])

    func getGenres() -> Single<[Genre]> {
        if shouldThrowForGenres {
            return genresRelay
                .flatMap { _ -> Single<[Genre]> in throw MoviesServiceMockError.someServiceErrorCase }
                .asSingle()
        } else {
            return genresRelay.asSingle()
        }
    }
    func getItems(forGenreId genreId: Int, page: Int) -> Single<[MovieItem]> {
        if shouldThrowForItems {
            return itemsRelay
                .flatMap { _ -> Single<[MovieItem]> in throw MoviesServiceMockError.someServiceErrorCase }
                .asSingle()
        } else {
            return itemsRelay.asSingle()
        }
    }
}
