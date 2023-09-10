//
//  ContentCollectionCell.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import UIKit
import Kingfisher
import SnapKit

final class ContentCollectionCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let labelsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let additionalInfoLabel = UILabel()

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
        contentView.layer.borderWidth = 1

        labelsStackView.axis = .vertical
        labelsStackView.spacing = Constants.stackViewSpacing
        labelsStackView.distribution = .fillProportionally

        [titleLabel, ratingLabel, additionalInfoLabel].forEach {
            $0.numberOfLines = 1
            $0.textAlignment = .center
            $0.font = .preferredFont(forTextStyle: .footnote)
            labelsStackView.addArrangedSubview($0)
        }
        additionalInfoLabel.numberOfLines = 2

        imageView.backgroundColor = .lightGray
        [imageView, labelsStackView].forEach {
            contentView.addSubview($0)
        }
    }

    private func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.edgeInset)
            make.width.equalToSuperview().dividedBy(Constants.imageViewWidthDivisionFactor)
            make.height.equalTo(imageView.snp.width).multipliedBy(Constants.imageViewHeightMultiplierFactor)
            make.centerX.equalToSuperview()
        }

        labelsStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Constants.textStackOffset)
            make.leading.bottom.trailing.equalToSuperview().inset(Constants.edgeInset)
        }
    }
}

// MARK: - Configure
extension ContentCollectionCell {
    func configure(with item: ContentCollectionItem) {
        imageView.kf.setImage(with: item.posterUrl)
        titleLabel.text = item.title
        ratingLabel.text = item.rating
        additionalInfoLabel.text = item.additionalInfo
    }
}

// MARK: - Constants
private extension ContentCollectionCell {
    enum Constants {
        static let edgeInset: CGFloat = 10
        static let imageViewWidthDivisionFactor = 3
        static let imageViewHeightMultiplierFactor = 1.5
        static let stackViewSpacing: CGFloat = 2
        static let textStackOffset: CGFloat = 5
    }
}
