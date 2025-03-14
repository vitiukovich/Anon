//
//  ChatCoordinator.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/23/25.
//

import UIKit

final class ChatCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(contact: ContactDTO) {
        let viewModel = ChatViewModel(contact: contact)
        let viewController = ChatViewController(viewModel: viewModel, coordinator: self, contact: contact)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func showProfile(contact: ContactDTO) {
        if let previousVC = navigationController.viewControllers.dropLast().last,
           previousVC is ProfileViewController {
            navigationController.popViewController(animated: true)
        } else {
            let coordinator = ProfileCoordinator(navigationController: navigationController)
            coordinator.start(contact: contact)
        }
    }
    
    func showImagePicker(chat: Chat) {
        let coordinator = ImagePickerCoordinator(navigationController: navigationController)
        coordinator.start(withChat: chat)
    }
    
    func showAutoDelete(vc: ChatViewController, option: AutoDeleteView.Option, contactID: String) {
        let alert = AutoDeleteView(selectedOption: option)
        alert.sendAction(to: contactID)
        alert.show(fromVC: vc)
    }

}
