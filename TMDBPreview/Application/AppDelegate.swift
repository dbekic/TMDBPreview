//
//  AppDelegate.swift
//  TMDBPreview
//
//  Created by Dejan Bekic on 9.9.23..
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window = createWindow()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window?.makeKeyAndVisible()

        return true
    }
}

// MARK: - Window and initial view controller
private extension AppDelegate {
    func createWindow() -> UIWindow? {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = Self.createTabBarController()

        return window
    }

    static func createTabBarController() -> UIViewController {
        let tabBarController = UITabBarController()

        let moviesCollectionViewController = createContentViewController(for: .movies)
        let tvShowsCollectionViewController = createContentViewController(for: .tvShows)

        tabBarController.viewControllers = [
            moviesCollectionViewController,
            tvShowsCollectionViewController,
        ]

        return tabBarController
    }

    static func createContentViewController(for contentCollectionType: ContentCollectionType) -> UIViewController {
        let viewController = ContentCollectionViewController()
        // vm binding
        switch contentCollectionType {
        case .movies:
            viewController.viewModelFactory = ContentCollectionViewModel.viewModel(
                service: MoviesService(),
                viewItemMapper: MovieMapper()
            )
        case .tvShows:
            viewController.viewModelFactory = ContentCollectionViewModel.viewModel(
                service: TvShowsService(),
                viewItemMapper: TvShowMapper()
            )
        }

        // styling
        viewController.tabBarItem.title = contentCollectionType.name
        viewController.tabBarItem.image = contentCollectionType.image
        viewController.view.backgroundColor = .white

        return viewController
    }
}

// MARK: - ContentCollectionType
// Helper type providing specific info and dependencies for tabs
private enum ContentCollectionType {
    case movies
    case tvShows

    var name: String {
        switch self {
        case .movies:
            return "Movies"
        case .tvShows:
            return "TV Shows"
        }
    }

    var image: UIImage? { // SFSymbols images
        switch self {
        case .movies:
            return UIImage(systemName: "film")
        case .tvShows:
            return UIImage(systemName: "play.tv")
        }
    }
}
