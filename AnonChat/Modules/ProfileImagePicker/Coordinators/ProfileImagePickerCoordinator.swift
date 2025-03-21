//
//  ProfileImagePickerCoordinator.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/21/25.
//

import UIKit

final class ProfileImagePickerCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = ProfileImagePickerViewModel()
        let viewController = ProfileImagePickerViewController(viewModel: viewModel, coordinator: self)
        guard navigationController.view.window != nil else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.present(viewController, animated: true)
    }
}
