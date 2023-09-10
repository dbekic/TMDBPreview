//
//  GenreCell.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import UIKit
import Kingfisher
import SnapKit
import RxSwift
import RxCocoa

final class GenreCell: UICollectionViewCell {
    fileprivate let genreButton = SelectionButton()

    var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        setupView()
        setupLayout()
    }

    private func setupView() {
        contentView.addSubview(genreButton)
    }

    private func setupLayout() {
        genreButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Configure
extension GenreCell {
    func configure(with item: GenreItem) {
        disposeBag = DisposeBag()
        genreButton.setTitle(item.name, for: .normal)
        genreButton.isSelected = item.isSelected
    }
}

// MARK: - Reactive
extension Reactive where Base: GenreCell {
    var cellSelection: Signal<GenreCell> {
        base.genreButton.rx
            .tap
            .filter { [weak base] in !(base?.genreButton.isSelected ?? false) }
            .asSignalOnErrorComplete()
            .mapTo(base)
    }
}

// MARK: - SelectionButton
private class SelectionButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor =  isHighlighted ? Constants.selectedColor : isSelected ? Constants.selectedColor : Constants.defaultBackgroundColor
        }
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Constants.selectedColor : Constants.defaultBackgroundColor
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        contentEdgeInsets = .init(top: 5, left: 15, bottom: 5, right: 15)
        setTitleColor(.black, for: .normal)
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderWidth = 1
    }

    private enum Constants {
        static let defaultBackgroundColor = UIColor.white
        static let selectedColor = UIColor.yellow
    }
}
