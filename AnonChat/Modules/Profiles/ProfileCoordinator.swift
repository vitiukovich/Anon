//
//  ProfileCoordinator.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/20/25.
//

import UIKit

final class ProfileCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(contact: ContactDTO) {
        let viewModel = ProfileViewModel(contact: contact)
        let viewController = ProfileViewController(contact: contact, viewModel: viewModel, coordinator: self)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showChat(withContact contact: ContactDTO) {
        if let previousVC = navigationController.viewControllers.dropLast().last,
           previousVC is ChatViewController {
            navigationController.popViewController(animated: true)
        } else {
            let coordinator = ChatCoordinator(navigationController: navigationController)
            coordinator.start(contact: contact)
        }
    }
    
    func showBlockView(from: UIViewController, contact: ContactDTO, action: UIAction) {
        let viewController = AlertViewController(title: "Block \(contact.username)?",
                                                 message: "Are you sure you want to block \(contact.username)? You can’t chat to \(contact.username) after blocked.",
                                                 imageName: "blockImage")
        
        viewController.addButton(withTitle: "Block", color: .wrongValueTextField, action: action)
        viewController.show(fromVC: from)
    }
    
    func showAutoDelete(vc: ProfileViewController, option: AutoDeleteView.Option, contactID: String) {
        let alert = AutoDeleteView(selectedOption: option)
        alert.sendAction(to: contactID)
        alert.show(fromVC: vc)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
}
