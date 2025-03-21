//
//  MainCoordinator.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit

class MainCoordinator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func showProfile(for contact: ContactDTO) {
        let coordinator = ProfileCoordinator(navigationController: navigationController)
        coordinator.start(contact: contact)
    }
    
    func showProfileSetting() {
        let coordinator = SettingCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    func showChat(for contact: ContactDTO) {
        let coordinator = ChatCoordinator(navigationController: navigationController)
        coordinator.start(contact: contact)
    }
    
    func removeChat(vc: UIViewController, actionForMe: UIAction, forEveryone: UIAction){
        let viewController = AlertViewController(title: "Remove Chat", message: "How do you want to remove chat?")
        viewController.addButton(withTitle: "Remove for Me", action: actionForMe)
        viewController.addButton(withTitle: "Remove for Everyone", color: .wrongValueTextField, action: forEveryone)
        viewController.show(fromVC: vc)
    }
}
