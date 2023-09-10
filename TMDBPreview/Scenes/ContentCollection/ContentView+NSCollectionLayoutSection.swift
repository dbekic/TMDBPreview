//
//  ContentView+NSCollectionLayoutSection.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 10.9.23..
//

import UIKit

extension ContentView {
    static func collectionsSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let viewWidth = layoutEnvironment.container.contentSize.width
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(viewWidth),
            heightDimension: .absolute(viewWidth / 2)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: CollectionViewConstants.contentLayoutGroupItemCount
        )

        // Section
        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    static func genresSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(60), heightDimension: .estimated(60)))
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(10),
            heightDimension: .absolute(layoutEnvironment.container.contentSize.height)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(CollectionViewConstants.genresInterItemSpacing)
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: CollectionViewConstants.leading, bottom: CollectionViewConstants.bottom, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous

        return section
    }

    enum CollectionViewConstants {
        static let contentLayoutGroupItemCount = 2
        static let leading: CGFloat = 16
        static let bottom: CGFloat = 10
        static let genresInterItemSpacing: CGFloat = 10
    }
}
