//
//  ContentCollectionViewModel.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import Foundation
import RxSwift
import RxCocoa

enum ContentCollectionViewModel {
    struct Input {
        let reload: Signal<Void>
        let nextPage: Signal<Void>
        let reloadOnError: Signal<Void>
        let selectedGenre: Signal<GenreItem>
    }

    struct Output {
        let genres: Driver<[GenreItem]>
        let items: Driver<[ContentCollectionItem]>
        let hasError: Driver<Bool>
    }

    static func viewModel<Service: ContentCollectionService, Mapper: ContentCollectionMapper>(
        service: Service,
        viewItemMapper: Mapper
    ) -> (Input) -> Output where Service.Item.Type == Mapper.TransformableItem.Type {
        return { [service, viewItemMapper] input in
            let genreStreams = Self.genreStreams(
                from: input,
                using: service
            )
            let itemStreams = Self.itemStreams(
                from: input,
                using: service,
                with: viewItemMapper,
                and: genreStreams.selectedGenre
            )

            let genreItems = Infallible
                .combineLatest(
                    itemStreams.items.take(1).mapToVoid(), // Wait for the first load before showing genres
                    genreStreams.genres,
                    genreStreams.selectedGenre,
                    resultSelector: { ($1, $2) }
                )
                .map { genres, selectedGenreItem in
                    genres.map { GenreItem(id: $0.id, name: $0.name, isSelected: selectedGenreItem.id == $0.id) }
                }
                .asDriverOnErrorComplete()

            let itemsWithGenreReload = Infallible
                .merge(
                    itemStreams.items,
                    genreStreams
                        .selectedGenre
                        .asObservable()
                        .skip(1)
                        .asInfallibleOnErrorComplete()
                        .mapTo([]) // set items to 0 when genre is changed
                )
                .asDriverOnErrorComplete()

            let hasError = Self.errorStream(
                from: input,
                with: genreStreams,
                and: itemStreams.itemsError
            )

            return Output(
                genres: genreItems,
                items: itemsWithGenreReload,
                hasError: hasError
            )
        }
    }
}

// MARK: - Streams and Models
private extension ContentCollectionViewModel {
    struct LoadingEvent {
        let incrementPage: Bool
    }

    struct GenreStreams {
        let genres: Infallible<[Genre]>
        let selectedGenre: Infallible<GenreItem>
        let genresError: Infallible<Error>
    }

    struct ItemStreams {
        let items: Infallible<[ContentCollectionItem]>
        let itemsError: Infallible<Error>
    }

    static func genreStreams(
        from input: Input,
        using service: some ContentCollectionService
    ) -> GenreStreams {
        let genresResult = Observable
            .merge(
                Observable<Void>.just(()), // Initial loading of genres
                input.reloadOnError.asObservable()
            )
            .flatMapLatest { _ in
                service
                    .getGenres()
                    .asObservable()
                    .debug("--- GENRES SERVICE")
                    .mapToResult()
            }
            .shareLatest()

        let genres = genresResult
            .compactMap(\.value)
            .take(1) // Load genres just once

        let initiallySelectedGenre = genres
            .compactMap { $0.first }
            .map {
                GenreItem(id: $0.id, name: $0.name, isSelected: true)
            }

        let selectedGenre = Infallible
            .merge(
                initiallySelectedGenre,
                input.selectedGenre.asInfallibleOnErrorComplete()
            )
            .shareLatest()

        return .init(
            genres: genres,
            selectedGenre: selectedGenre,
            genresError: genresResult.compactMap(\.error)
        )
    }

    static func itemStreams<Service: ContentCollectionService, Mapper: ContentCollectionMapper>(
        from input: Input,
        using service: Service,
        with viewItemMapper: Mapper,
        and selectedGenre: Infallible<GenreItem>
    ) -> ItemStreams where Service.Item.Type == Mapper.TransformableItem.Type {
        let pageCountResettingEvents = Signal
            .merge(
                Signal<Void>.just(()), // Initial loading event
                input.reload.mapToVoid(),
                input.selectedGenre.mapToVoid(),
                input.reloadOnError.mapToVoid()
            )
            .mapTo(LoadingEvent(incrementPage: false))
            .asInfallibleOnErrorComplete()
        let pageCountIncrementEvent = input
            .nextPage
            .mapTo(LoadingEvent(incrementPage: true))
            .asInfallibleOnErrorComplete()

        let loadingEventWithPageNumber = Infallible
            .merge(
                pageCountResettingEvents,
                pageCountIncrementEvent
            )
            .scan(
                1, // Initial page
                accumulator: { currentPage, loadingEvent in
                    loadingEvent.incrementPage ? currentPage + 1 : 1
                }
            )

        let genreAndPage = Infallible
            .combineLatest(
                selectedGenre,
                loadingEventWithPageNumber,
                resultSelector: { ($0, $1) }
            )

        let itemsResult = genreAndPage
            .flatMapLatest { genre, page in
                service
                    .getItems(forGenreId: genre.id, page: page)
                    .map { $0.map { viewItemMapper.transform(contentCollectionItemConvertibleItem: $0) } }
                    .map { items in (page, items) }
                    .asObservable()
                    .mapToResult()
            }
            .shareLatest()

        let items = itemsResult
            .compactMap(\.value)
            .scan([ContentCollectionItem](), accumulator: { currentItems, pageAndNewItems in
                let (page, newItems) = pageAndNewItems
                return page == 1 ? newItems : currentItems + newItems
            })

        return .init(
            items: items,
            itemsError: itemsResult.compactMap(\.error)
        )
    }

    static func errorStream(
        from input: Input,
        with genreStreams: GenreStreams,
        and itemsError: Infallible<Error>
    ) -> Driver<Bool> {
        Infallible
            .merge(
                input
                    .reloadOnError
                    .mapTo(false)
                    .asInfallibleOnErrorComplete(),
                genreStreams
                    .genresError
                    .mapTo(true),
                genreStreams
                    .selectedGenre
                    .mapTo(false)
                    .asObservable()
                    .skip(1)
                    .asInfallibleOnErrorComplete(),
                itemsError
                    .mapTo(true)
            )
            .asDriverOnErrorComplete()
    }
}
