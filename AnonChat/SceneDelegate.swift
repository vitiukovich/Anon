//
//  SceneDelegate.swift
//  chatApp
//
//  Created by Stanislav Vitiuk on 12/22/24.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        if !UserDefaults.standard.bool(forKey: "EULAAccepted") {
            window.rootViewController = EULAViewController()
        } else {
            if let uid = Auth.auth().currentUser?.uid,
               uid == UserManager.shared.currentUID,
               UserDefaults.standard.bool(forKey: "isRememberMeSelected") {
                MessageManager.shared.startListeningForMessages(for: uid)
                NetworkMessageService.shared.listenForDeleteRequests(for: uid)
                ChatManager.shared.startListeningForDeleteChatSignal(for: uid)
                NetworkChatService.shared.startListeningForDeleteTimer(for: uid)
                showMainScreen()
            } else {
                showLoginScreen()
            }
        }
        
        let theme = UserDefaults.standard.bool(forKey: "darkMode") ? UIUserInterfaceStyle.dark : .unspecified
        window.overrideUserInterfaceStyle = theme
        
        window.makeKeyAndVisible()
        
    }
    
    func showMainScreen() {
        let navVC = UINavigationController()
        let coordinator = MainCoordinator(navigationController: navVC)
        let mainVM = MainViewModel(coordinator: coordinator)
        let mainVC = MainViewController(viewModel: mainVM, coordinator: coordinator)
        
        navVC.navigationBar.isHidden = true
        navVC.viewControllers = [mainVC]
        window?.rootViewController = navVC
    }

    func showLoginScreen() {
        let navVC = UINavigationController()
        let coordinator = LoginCoordinator()
        let loginVC = LoginViewController(coordinator: coordinator)
    
        navVC.navigationBar.isHidden = true
        navVC.viewControllers = [loginVC]
        window?.rootViewController = navVC
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}


}

