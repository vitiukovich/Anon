//
//  MainViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit
import Combine

class MainViewModel {
    @Published var networkContacts: [ContactDTO] = []
    @Published var isSearching: Bool = false
    @Published var isNewMassage: Bool = false
    @Published var query: String = ""
    @Published var profileImage: String = ""
    @Published var newMessage: MessageDTO? = nil
    
    
    weak var parentVC: MainViewController?
    
    private var localContacts: [ContactDTO] = []
    private var searchWorkItem: DispatchWorkItem?
    private var cancellables = Set<AnyCancellable>()
    
    private let coordinator: MainCoordinator
    private let contactManager = ContactManager.shared
    private let chatManager = ChatManager.shared
    private let currentUID: String! = UserManager.shared.currentUID

    
    


    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        bindMessagesNotification()
        fetchLocalContacts()
        fetchLocalChats()
        bindUserProfileImage()
    }
    
    deinit {
        cancellables.removeAll()
    }

    private func bindMessagesNotification() {
        NotificationCenter.default.publisher(for: .newMessageSaved)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchLocalChats()
            } .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .newMessageReceived)
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] notification in
                guard let self = self else { return }
                
                guard let message = notification.userInfo?["message"] as? MessageDTO else {
                    return
                }
                guard self.shouldShowNotification(for: message.senderID) else {
                    self.isNewMassage = true
                    return
                }
                self.contactManager.fetchContact(byUID: message.senderID) { result in
                    switch result {
                    case .success(let contact):
                        let notification = MessageNotificationView(sender: contact.username, message: message.text ?? "", image: contact.profileImage) {
                            self.coordinator.showChat(for: contact)
                        }
                        
                        notification.show()
                    case .failure(_): break
                    }
                }
                self.newMessage = message
            }
            .store(in: &cancellables)
    }

    private func bindUserProfileImage() {
        UserManager.shared.$profileImage
            .removeDuplicates()
            .sink { [weak self] newImage in
                self?.profileImage = newImage
            }
            .store(in: &cancellables)
    }
    
    func fetchLocalChats() {
        let updatedChats = chatManager.loadAllChats(for: currentUID)
            .sorted(by: { $0.lastMessageDate > $1.lastMessageDate })

        DispatchQueue.main.async { [weak self] in
            guard let self, let tableView = self.parentVC?.chatsTableView else { return }
            tableView.updateChats(updatedChats)
        }
    }
    
    func fetchLocalContacts() {
        localContacts = contactManager.fetchLocalContacts().sorted { $0.username < $1.username }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.parentVC?.contactsTableView.updateContacts(network: [], local: self.localContacts, isSearching: false)
        }
    }
    
    func searchContacts(query: String) {
        searchWorkItem?.cancel()
        guard !query.isEmpty else {
            fetchLocalContacts()
            return
        }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let sortedLocalContacts = localContacts.filter { $0.username.lowercased().contains(query.lowercased()) }
            self.localContacts = sortedLocalContacts
            contactManager.searchContacts(query: query) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let contacts):
                        self.parentVC?.contactsTableView.updateContacts(network: contacts, local: sortedLocalContacts, isSearching: true)
                    case .failure(_):
                        break
                    }
                }
            }
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    func deleteChat(_ chat: ChatDTO, forEveryone: Bool) {
        do {
            try chatManager.deleteChat(chat, forEveryone: forEveryone)
            DispatchQueue.main.async { [weak self] in
                self?.fetchLocalChats()
            }
        } catch {
        }
    }
    
    private func shouldShowNotification(for userID: String) -> Bool {
        guard let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else { return true }

        if let navVC = topVC as? UINavigationController, let visibleVC = navVC.visibleViewController {
            if let visibleVC = visibleVC as? ChatViewController {
                if visibleVC.userID == userID {
                    return false
                }
            } else if visibleVC is MainViewController {
                return false
            }
        }
        return true
    }
    

}
