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
    
    func showReport(vc: ChatViewController, contact: ContactDTO) {
        let alert = AlertViewController(title: "Report User", message: "Are you sure you want to report this user? This action cannot be undone.")
        alert.addButton(withTitle: "Report", action: UIAction { _ in
            let email = "vitiukovich@icloud.com"
            let subject = "Complaint about user \(contact.username)"
            let body = "Please describe the issue with this user ..."

            if let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        })
        alert.show(fromVC: vc)
    }

}
