//
//  SceneDelegate.swift
//  mobiquity ios challenge
//
//  Created by Gustavo Campos on 27/8/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: scene)

        let viewController = RecentSearchListViewController(
            viewModel: .init(
                photoSearchService: .live,
                recentSearchItemsService: .live
            ),
            recentSearchViewModel: .init(service: .live)
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

