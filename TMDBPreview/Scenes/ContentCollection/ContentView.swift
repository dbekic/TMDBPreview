//
//  ContentView.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import UIKit
import RxSwift
import RxCocoa

final class ContentView: UIView {
    private let stackView = UIStackView()
    // genres collectionView
    fileprivate lazy var genresCollectionView = setupGenresCollectionView()
    private lazy var genreDataSource = setupGenreDataSource()
    fileprivate var genresSection = GenreSection(id: 0, items: []) { didSet { applyGenreSnapshot() } }
    fileprivate let cellSelectionRelay = PublishRelay<GenreCell>()

    // content collection view
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate lazy var contentCollectionView = setupCollectionView()
    private lazy var contentDataSource = setupContentDataSource()
    fileprivate var contentSection = ContentSection(id: 0, items: []) { didSet { applyContentSnapshot() } }
    // data source status updates, needed for more accurate bottom detection
    fileprivate let contentDataSoruceUpdated = PublishRelay<Void>()
    fileprivate let isContentDataSourceEmpty = BehaviorRelay(value: true)

    // container and error views
    private let contentAndErrorContainerView = UIView()
    fileprivate let errorView = ErrorView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        initialize()
    }

    private func initialize() {
        setupView()
        setupLayout()
    }

    private func setupView() {
        stackView.axis = .vertical
        stackView.addArrangedSubview(genresCollectionView)
        stackView.addArrangedSubview(contentAndErrorContainerView)
        addSubview(stackView)

        genresCollectionView.isHidden = true
        genresCollectionView.backgroundColor = .lightGray
        contentCollectionView.refreshControl = refreshControl

        contentAndErrorContainerView.addSubview(contentCollectionView)
        contentAndErrorContainerView.addSubview(errorView)
        errorView.isHidden = true // hide error view initially
    }

    private func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        genresCollectionView.snp.makeConstraints { make in
            make.height.equalTo(Constants.genresCollectionViewHeight)
        }

        [contentCollectionView, errorView].forEach {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

// MARK: - Constants
private extension ContentView {
    enum Constants {
        static let genresCollectionViewHeight: CGFloat = 100
        static let contentCellReuseId = String(describing: ContentCell.self)
        static let genreCellReuseId = String(describing: GenreCell.self)
    }
}

// MARK: - Types
extension ContentView {
    // section model
    fileprivate struct Section<Item: Identifiable> {
        let id: Int
        let items: [Item]
    }

    // genres
    fileprivate typealias GenreSection = Section<GenreItem>
    private typealias GenreSnapshot = NSDiffableDataSourceSnapshot<Int, GenreItem>
    fileprivate typealias GenreDataSource = UICollectionViewDiffableDataSource<Int, GenreItem>

    // content
    private typealias ContentCell = ContentCollectionCell
    fileprivate typealias ContentItem = ContentCollectionItem
    fileprivate typealias ContentSection = Section<ContentItem>
    private typealias ContentSnapshot = NSDiffableDataSourceSnapshot<Int, ContentItem>
    fileprivate typealias ContentDataSource = UICollectionViewDiffableDataSource<Int, ContentItem>
}

// MARK: - Reactive
extension Reactive where Base: ContentView {
    var genreItems: Binder<[GenreItem]> {
        Binder(base) { view, items in
            view.genresSection = ContentView.GenreSection(id: 0, items: items)
        }
    }

    var genreSelection: Signal<GenreItem> {
        base.cellSelectionRelay
            .map { [weak base] cell -> GenreItem? in
                guard let indexPath = base?.genresCollectionView.indexPath(for: cell)
                else { return nil }

                return base?.genresSection.items[safe: indexPath.row]
            }
            .asSignalOnErrorComplete()
            .compactMap()
    }

    var contentItems: Binder<[ContentCollectionItem]> {
        Binder(base) { view, items in
            view.contentSection = ContentView.ContentSection(id: 0, items: items)
        }
    }

    var pullToRefesh: Signal<Void> {
        base.refreshControl.rx
            .controlEvent(.valueChanged)
            .asSignal()
            .mapToVoid()
    }

    var isRefreshing: Binder<Bool> {
        base.refreshControl.rx.isRefreshing
    }

    var nextPageEvent: Signal<Void> {
        base.contentCollectionView.rx
            .reachedBottomOnceWith(
                restart: .merge(
                    pullToRefesh.asDriverOnErrorComplete(),
                    base.contentDataSoruceUpdated.asDriverOnErrorComplete()
                )
            )
            .withLatestFrom(base.isContentDataSourceEmpty.asDriver())
            .filter { !$0 }
            .mapToVoid()
            .asSignalOnErrorComplete()
    }

    var retryOnError: Signal<Void> {
        base.errorView.rx.action
    }

    var isErrorViewHidden: Binder<Bool> {
        base.errorView.rx.isHidden
    }

    var scrollCollectionViewToTop: Binder<Void> {
        Binder(base) { view, _ in
            guard view.contentCollectionView.contentSize.height > 0
            else { return }

            view.contentCollectionView.scrollToItem(
                at: .init(row: 0, section: 0),
                at: .top,
                animated: false
            )
        }
    }
}

// MARK: - Genres UICollectionView
private extension ContentView {
    func setupGenresCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment -> NSCollectionLayoutSection? in
            Self.genresSection(layoutEnvironment: layoutEnvironment)
        }
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: Constants.genreCellReuseId)

        return collectionView
    }

    func setupGenreDataSource() -> GenreDataSource {
        GenreDataSource(collectionView: genresCollectionView) { [cellSelectionRelay] collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.genreCellReuseId, for: indexPath) as? GenreCell else { fatalError("Failed to dequeue reusable cell") }
            cell.configure(with: item)
            cell.rx
                .cellSelection
                .emit(to: cellSelectionRelay)
                .disposed(by: cell.disposeBag)
            return cell
        }
    }

    func applyGenreSnapshot() {
        var snapshot = GenreSnapshot()
        snapshot.appendSections([genresSection.id])
        snapshot.appendItems(genresSection.items, toSection: genresSection.id)
        genreDataSource.apply(snapshot)

        if snapshot.numberOfItems(inSection: 0) > 0 {
            genresCollectionView.isHidden = false
        }

        // scroll the collection view to the left edge
        if let (offset, _) = genresSection.items.enumerated().first(where: { $0.1.isSelected }) {
            genresCollectionView.scrollToItem(at: .init(row: offset, section: 0), at: .bottom, animated: true)
        }
    }
}

// MARK: - CollectionView setup
private extension ContentView {
    func setupCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment -> NSCollectionLayoutSection? in
            Self.collectionsSection(layoutEnvironment: layoutEnvironment)
        }
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.register(ContentCell.self, forCellWithReuseIdentifier: Constants.contentCellReuseId)

        return collectionView
    }

    func setupContentDataSource() -> ContentDataSource {
        ContentDataSource(collectionView: contentCollectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.contentCellReuseId, for: indexPath) as? ContentCell else { fatalError("Failed to dequeue reusable cell") }
            cell.configure(with: item)
            return cell
        }
    }

    func applyContentSnapshot() {
        var snapshot = ContentSnapshot()
        snapshot.appendSections([contentSection.id])
        snapshot.appendItems(contentSection.items, toSection: contentSection.id)
        contentDataSource.apply(snapshot)

        contentDataSoruceUpdated.accept(())
        isContentDataSourceEmpty.accept(snapshot.numberOfItems(inSection: 0) == 0)
    }
}
