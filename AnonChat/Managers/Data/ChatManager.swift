//
//  ChatManager.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import Firebase
import RealmSwift

final class ChatManager {
    static let shared = ChatManager()
    private init() {}

    private let localService = LocalChatService.shared
    private let networkService = NetworkChatService.shared

    func loadAllChats(for uid: String) -> [ChatDTO] {
        localService.loadAllChats(for: uid).map { $0.toDTO() }.sorted { $0.lastMessageDate > $1.lastMessageDate }
    }

    func getOrCreateChat(for currentUID: String, with userID: String) -> Chat? {
        do {
            let result = try localService.getOrCreateChat(contactID: userID, currentUID: currentUID)
            return result
        } catch {
            Logger.log("Error while getting or creating chat: \(error.localizedDescription)", level: .error)
            return nil
        }
    }
    
    func deleteChat(_ chat: ChatDTO, forEveryone: Bool) {
        do {
            try localService.deleteChat(forContactID: chat.contactID)
        } catch {
            Logger.log("Error while deleting chat: \(error.localizedDescription)", level: .error)
        }
        if forEveryone {
            networkService.sendDeleteChatSignal(chat)
        }
    }
    
    func deleteChat(forContactID: String) {
        do {
            try localService.deleteChat(forContactID: forContactID)
        } catch {
            Logger.log("Error while deleting chat: \(error.localizedDescription)", level: .error)
        }
    }
    
    func deleteMessagesFromChat(forContactID: String) {
        do {
            try localService.deleteMessagesFromChat(forContactID: forContactID)
        } catch {
            Logger.log("Error while deleting messages from chat: \(error.localizedDescription)", level: .error)
        }
    }

    func startListeningForDeleteChatSignal(for uid: String) {
        networkService.listenForChatDeletions(for: uid)
    }

    func fetchChatImagesFromRealm(with contactID: String) -> [UIImage] {
        localService.fetchChatImagesFromRealm(with: contactID)
    }
    
    func stopListeningForDeleteChatSignal() {
        networkService.stopListenForChatDeletions()
    }
    
}
