//
//  ChatViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/23/25.
//

import UIKit
import Combine
import RealmSwift

final class ChatViewModel {
    let chatDTO: ChatDTO
    let chat: Chat
    lazy var isContactAvailable: Bool = contact.status == "Available" ? true : false
    @Published var messages: [MessageDTO] = []
    @Published var errorMessage: String? = nil
    
    private let contact: ContactDTO
    private var cancellables = Set<AnyCancellable>()
    private var messagesToken: NotificationToken?
    
    init(contact: ContactDTO) {
        self.contact = contact
        guard let chat = ChatManager.shared.getOrCreateChat(for: UserManager.shared.currentUID ?? "", with: contact.userID) else {
            fatalError("❌ Error creating/getting chat!")
        }
        self.chat = chat
        self.chat.markAsRead()
        self.chatDTO = chat.toDTO()
        fetchMessages()
        observeMessages()
    }
    
    deinit {
        messagesToken?.invalidate()
        messagesToken = nil
        cancellables.removeAll()
    }
    
    func fetchMessages() {
        let messages = Array(chat.messages).sorted { $0.date > $1.date }
        self.messages = messages.map { $0.toDTO() }
    }
    
    func cancelObservingMessages() {
        messagesToken?.invalidate()
        messagesToken = nil
    }
    
    func observeMessages() {
        messagesToken?.invalidate()
        messagesToken = chat.messages.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let initialMessages):
                self.messages = initialMessages.map { $0.toDTO() }.sorted { $0.date > $1.date }
            case .update(let updatedMessages, _, _, _):
                self.messages = updatedMessages.map { $0.toDTO() }.sorted { $0.date > $1.date }
            case .error(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        
        guard let currentUID = UserManager.shared.currentUID else { return }
        if chat.realm == nil { return }
        let message = Message(senderID: currentUID, recipientID: contact.userID, text: text)
        MessageManager.shared.sendMessage(to: chat, message: message) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(()):
                completion(.success(()))
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }
}
