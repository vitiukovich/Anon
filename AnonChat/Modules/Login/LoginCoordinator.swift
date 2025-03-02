//
//  LoginCoordinator.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit

class LoginCoordinator {
    
    func start(in window: UIWindow) {
        let loginVC = LoginViewController( coordinator: self)
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
        
    }
    
    func navigateToMainView() {
        let navigationController = UINavigationController()
        
        let coordinator = MainCoordinator(navigationController: navigationController)
        let viewModel = MainViewModel(coordinator: coordinator)
        let viewController = MainViewController(viewModel: viewModel, coordinator: coordinator)
        
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.isNavigationBarHidden = true

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navigationController
            UIView
                .transition(
                    with: window,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: nil,
                    completion: nil
                )
        }
    }
    
    func resetAppToLoginScreen() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }

        let viewController = LoginViewController(coordinator: self)
        let navigationController = UINavigationController(rootViewController: viewController)

        sceneDelegate.window?.rootViewController = navigationController
        sceneDelegate.window?.makeKeyAndVisible()
    }
}
