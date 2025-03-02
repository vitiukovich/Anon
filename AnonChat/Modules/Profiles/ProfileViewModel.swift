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
    
    private let contactManager = ContactManager.shared
    private let contact: ContactDTO
    
    
    init(contact: ContactDTO) {
        self.contact = contact
        self.isContactAdded = contactManager.isContactExists(username: contact.username)
        self.isContactBlocked = contact.isContactBlocked
        self.images = ChatManager.shared.fetchChatImagesFromRealm(with: contact.userID)
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
                }
            }
        }
    }
    
}
