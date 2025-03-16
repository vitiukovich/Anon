//
//  SettingViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/18/25.
//

import UIKit
import Combine

final class SettingViewModel {
    
    @Published var profileImage: String = ""
    @Published var alertMessage: String? = nil
    
    var isDarkModeOn: Bool {
        get { UserDefaults.standard.bool(forKey: "darkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "darkMode") }
    }
    
    var isNotificationsOn: Bool {
        get { UserDefaults.standard.bool(forKey: "notificationsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "notificationsEnabled") }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let coordinator: SettingCoordinator

    init(coordinator: SettingCoordinator) {
        self.coordinator = coordinator
        
        bindUserProfileImage()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private func bindUserProfileImage() {
        UserManager.shared.$profileImage
            .removeDuplicates()
            .sink { [weak self] newImage in
                self?.profileImage = newImage
            }
            .store(in: &cancellables)
    }
    
    func notificationToggle(_ value: Bool) {
        isNotificationsOn = value
        SettingManager.shared.turnOnNotification(value)
    }
    
    func darkModeToggle(_ value: Bool) {
        isDarkModeOn = value
        SettingManager.shared.turnOnDarkMode(value)
    }
    
    func showBlockedUsers() {
        BlockListManager.shared.getBlockedContacts { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let contacts):
                coordinator.showBlockedUsers(contacts: contacts)
            case .failure(let error):
                alertMessage = error.localizedDescription
            }
        }
    }

    func clearDeviceData() {
        SettingManager.shared.clearRealmData { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                alertMessage = "Device data cleared successfully."
            case .failure(let error):
                alertMessage = error.localizedDescription
            }
        }
    }

    func deleteAccount() {
        SettingManager.shared.deleteCurrentUser { [weak self] result in
            guard let self else { return }
            switch result {
            case .success: coordinator.logout()
            case .failure(let error): alertMessage = error.localizedDescription
            }
        }
    }

    
    func logout() {
        UserManager.shared.logoutUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_):
                break
            case .success:
                coordinator.logout()
            }
        }
        
    }
}
