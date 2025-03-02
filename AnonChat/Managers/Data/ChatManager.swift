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
       
        return localService.loadAllChats(for: uid).map { $0.toDTO() }.sorted { $0.lastMessageDate > $1.lastMessageDate }
        
    }

    func getOrCreateChat(for currentUID: String, with userID: String) -> Chat? {
        do {
            let result = try localService.getOrCreateChat(contactID: userID, currentUID: currentUID)
            return result
        } catch {
            return nil
        }
    }
    
    func deleteChat(_ chat: ChatDTO, forEveryone: Bool) throws {
        try localService.deleteChat(forContactID: chat.contactID)

        if forEveryone {
            networkService.sendDeleteChatSignal(chat)
        }
    }
    
    func deleteChat(forContactID: String) throws {
        try localService.deleteChat(forContactID: forContactID)
    }
    
    func deleteMessagesFromChat(forContactID: String) throws {
        try localService.deleteMessagesFromChat(forContactID: forContactID)
    }

    func startListeningForDeleteChatSignal(for uid: String) {
        networkService.listenForChatDeletions(for: uid)
    }

    func fetchChatImagesFromRealm(with contactID: String) -> [UIImage] {
        return localService.fetchChatImagesFromRealm(with: contactID)
    }
    
    func stopListeningForDeleteChatSignal() {
        networkService.stopListenForChatDeletions()
    }
    
}
