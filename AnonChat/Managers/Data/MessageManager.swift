//
//  MessageManager.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/1/25.
//

import Foundation

final class MessageManager {
    
    static let shared = MessageManager()
    private init() {}
    
    func deleteMessage(_ message: MessageDTO, fromChat chatID: String, contactID: String) {
        do {
            try LocalMessageService.shared.deleteMessage(fromChat: chatID, messageDate: message.date)
            NetworkMessageService.shared.sendDeleteRequest(to: contactID, message: message)
        } catch {}
    }
    
    func sendMessage(to chat: Chat, message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkContactService.shared.fetchContact(byUID: chat.contactID) { result in
            switch result {
            case .success(let contact):
                NetworkMessageService.shared.sendMessage(message.toDTO(), to: contact) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        do {
                            try LocalMessageService.shared.saveMessage(message, to: chat)
                            completion(.success(()))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func startListeningForMessages(for uid: String) {
        NetworkMessageService.shared.listenForMessages(for: uid) { message in
            do {
                let chat = try LocalChatService.shared.getOrCreateChat(contactID: message.senderID, currentUID: message.recipientID)
                try LocalMessageService.shared.saveIncomingMessage(message.toMessage(), to: chat)
                
                NotificationCenter.default.post(name: .newMessageReceived, object: nil, userInfo: ["message": message])
            } catch {
            }
        }
    }
    
    func stopListeningForMessages() {
        NetworkMessageService.shared.stopListening()
    }
}
