//
//  ErrorView.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import UIKit
import RxSwift
import RxCocoa

final class ErrorView: UIView {
    private let stackView = UIStackView()
    private let errorLabel = UILabel()
    fileprivate let actionButton = UIButton()

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
        backgroundColor = .white
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(actionButton)
        addSubview(stackView)

        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.font = .preferredFont(forTextStyle: .body)
        errorLabel.text = Constants.errorLabelText

        actionButton.setTitle(Constants.actionButtonTitle, for: .normal)
        actionButton.setTitleColor(.black, for: .normal)
        actionButton.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        actionButton.layer.borderWidth = 1
    }

    private func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Constants.inset)
        }
    }
}

// MARK: - Constants
private extension ErrorView {
    enum Constants {
        static let inset: CGFloat = 20
        static let stackViewSpacing: CGFloat = 10
        static let actionButtonTitle = "Tap to retry"
        static let errorLabelText = "Something went wrong"
        static let actionButtonHeight: CGFloat = 40
        static let actionButtonWidth: CGFloat = 120
    }
}

// MARK: - Reactive
extension Reactive where Base: ErrorView {
    var action: Signal<Void> {
        base.actionButton.rx
            .tap
            .asSignal()
    }
}
