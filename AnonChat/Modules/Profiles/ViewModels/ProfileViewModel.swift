//
//  ProfileViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/20/25.
//

import UIKit
import Combine

final class ProfileViewModel {
    @Published var isContactAdded: Bool = false
    @Published var isContactBlocked: Bool = false
    @Published var errorMessage: String? = nil
    @Published var images: [UIImage] = []
    @Published var autoDeleteOption: AutoDeleteView.Option = .off
    
    let contactID: String
    
    private var cancellables: Set<AnyCancellable> = []
    private let chat: Chat?
    private let contactManager = ContactManager.shared
    private let contact: ContactDTO
    
    init(contact: ContactDTO) {
        self.contact = contact
        self.isContactAdded = contactManager.isContactExists(username: contact.username)
        self.isContactBlocked = contact.isContactBlocked
        self.images = ChatManager.shared.fetchChatImagesFromRealm(with: contact.userID)
        self.chat = ChatManager.shared.getOrCreateChat(for: UserManager.shared.currentUID ?? "", with: contact.userID)
        self.contactID = contact.userID
        switch chat?.deleteTimer {
        case 0, nil: autoDeleteOption = .off
        case 1: autoDeleteOption = .oneHour
        case 2: autoDeleteOption = .oneDay
        case 3: autoDeleteOption = .oneWeek
        default: break
        }
        bindNotifications()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    func bindNotifications() {
        NotificationCenter.default.publisher(for: .newAutoDeleteTime)
            .sink { [weak self] notification in
                self?.handleAutoDeleteTime(notification)
            }
            .store(in: &cancellables)
    }
    
    func toggleContactPressed() {
        if isContactAdded {
            let result = contactManager.deleteContact(contact)
            switch result {
            case .success:
                isContactAdded = false
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        } else {
            let result = contactManager.saveContact(contact)
            switch result {
            case .success:
                isContactAdded = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    func toggleBlockPressed() {
        if isContactBlocked {
            BlockListManager.shared.unblockUser(userID: contact.userID) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(()):
                    isContactBlocked = false
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    Logger.log(error.localizedDescription, level: .error)
                }
            }
        } else {
            BlockListManager.shared.blockUser(userID: contact.userID) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(()):
                    isContactBlocked = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    Logger.log(error.localizedDescription, level: .error)
                }
            }
        }
    }
    
    @objc private func handleAutoDeleteTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let deleteTime = userInfo["deleteTime"] as? Int else { return }
        
        switch deleteTime {
        case 0: autoDeleteOption = .off
        case 1: autoDeleteOption = .oneHour
        case 2: autoDeleteOption = .oneDay
        case 3: autoDeleteOption = .oneWeek
        default: break
        }
    }
    
}
