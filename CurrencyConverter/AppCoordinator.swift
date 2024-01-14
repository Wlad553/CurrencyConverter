//
//  AppCoordinator.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import UIKit
import XCoordinator

enum AppRoute: Route {
    case main
    case currencies
}

final class AppCoordinator: NavigationCoordinator<AppRoute> {
    private let navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()
    
    init() {
        super.init(rootViewController: navigationController,
                   initialRoute: .main)
    }
    
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
        case .main:
            let viewModel = MainViewModel(router: weakRouter)
            let viewController = MainViewController(viewModel: viewModel)
            return .push(viewController)
            
        case .currencies:
            let viewModel = CurrenciesViewModel(router: weakRouter)
            let viewController = CurrenciesViewController(viewModel: viewModel)
            let navController = UINavigationController(rootViewController: viewController)
            return .present(navController)
        }
    }
}
