//
//  ContentCollectionViewController.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import UIKit
import RxSwift

final class ContentCollectionViewController: UIViewController {
    typealias Input = ContentCollectionViewModel.Input
    typealias Output = ContentCollectionViewModel.Output

    var viewModelFactory: (Input) -> Output = { _ in fatalError("Need to provide a factory method first") }

    private let disposeBag = DisposeBag()
    private lazy var contentView = ContentView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
}

private extension ContentCollectionViewController {
    func setupView() {
        let input = Input(
            reload: contentView.rx.pullToRefesh,
            nextPage: contentView.rx.nextPageEvent,
            reloadOnError: contentView.rx.retryOnError,
            selectedGenre: contentView.rx.genreSelection
        )

        let output = viewModelFactory(input)
        output
            .genres
            .drive(contentView.rx.genreItems)
            .disposed(by: disposeBag)

        output
            .items
            .drive(contentView.rx.contentItems)
            .disposed(by: disposeBag)

        output
            .items
            .map { $0.isEmpty }
            .startWith(true)
            .drive(contentView.rx.isRefreshing)
            .disposed(by: disposeBag)

        output
            .hasError
            .map { !$0 }
            .drive(contentView.rx.isErrorViewHidden)
            .disposed(by: disposeBag)

        output
            .hasError
            .filter { $0 }
            .mapToVoid()
            .drive(contentView.rx.scrollCollectionViewToTop)
            .disposed(by: disposeBag)
    }
}
