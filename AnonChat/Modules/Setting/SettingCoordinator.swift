//
//  SettingCoordinator.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/18/25.
//

import UIKit

final class SettingCoordinator {
    
    private let navigationController: UINavigationController
    private lazy var openProfile: (ContactDTO) -> Void = { contact in
        self.showProfile(contact: contact)
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = SettingViewModel(coordinator: self)
        let profileSettingVC = SettingViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(profileSettingVC, animated: true)
    }
    
    func showLogOutAlert(vc: UIViewController, action: UIAction) {
        let viewController = AlertViewController(title: "Log Out",
                                                 message: "Are you sure you want to log out? You won't be able to receive messages while you're offline")
        viewController.addButton(withTitle: "Log out", color: .wrongValueTextField, action: action)
        viewController.show(fromVC: vc)
    }
    
    func logout(){
        DispatchQueue.main.async {
            let coordinator = LoginCoordinator()
            coordinator.resetAppToLoginScreen()
        }
    }
    
    func navigateToImagePicker() {
        let coordinator = ProfileImagePickerCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func showBlockedUsers(contacts: [ContactDTO]) {
        let vc = BlockListViewController(contacts, coordinator: self, openProfile: openProfile)
        vc.modalPresentationStyle = .overFullScreen
        
        navigationController.viewControllers.last?.present(vc, animated: true)
    }
    
    func showDeleteAccountConfirmation(vc: UIViewController, action: UIAction) {
        let viewController = AlertViewController(title: "Delete Account",
                                                 message: "Are you sure you want to delete your account? Once deleted, the data cannot be restored")
        viewController.addButton(withTitle: "Delete", color: .wrongValueTextField, action: action)
        viewController.show(fromVC: vc)
    }
    
    func showClearDeviceConfirmation(vc: UIViewController, action: UIAction) {
        let viewController = AlertViewController(title: "Clear All Data",
                                                 message: "Are you sure you want to delete all data on this device? The data cannot be restored")
        viewController.addButton(withTitle: "Clear", color: .wrongValueTextField, action: action)
        viewController.show(fromVC: vc)
    }
    
    func showProfile(contact: ContactDTO) {
        let coordinator = ProfileCoordinator(navigationController: navigationController)
        coordinator.start(contact: contact)
    }
    
    func showSupportChat() {
        ContactManager.shared.fetchContact(byUID: "POTM94UaCZMYO4fRQGrjatPyWAK2", completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let contact):
                let coordinator = ChatCoordinator(navigationController: navigationController)
                navigationController.popViewController(animated: true)
                coordinator.start(contact: contact)
                
            case .failure(_): break
            }
        })
    }
    
    func showContactUs(vc: SettingViewController) {
        let viewController = AlertViewController(title: "Contact Us",
                                                 message: "Choose a contact method")
        viewController.addButton(withTitle: "Send Email", color: .activeButton, action: UIAction { _ in
            if let url = URL(string: "mailto:vitiukovich@icloud.com") {
                UIApplication.shared.open(url)
            }
        })
        viewController.addButton(withTitle: "Contacts", color: .activeButton, action: UIAction {_ in
            if let url = URL(string: "https://vitiukovich.github.io/anonchat-privacy/support.html") {
                UIApplication.shared.open(url)
            }
        })
        viewController.show(fromVC: vc)
    }
}
