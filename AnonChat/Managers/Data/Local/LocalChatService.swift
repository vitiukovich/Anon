//
//  LocalChatService.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/27/25.
//

import UIKit
import RealmSwift
import Foundation
import CryptoKit


final class LocalChatService {
    
    static let shared = LocalChatService()  

    private init() {
        startAutoDeleteTimer()
    }

    func startAutoDeleteTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            let realm = try! Realm()
            let allChats = realm.objects(Chat.self)

            for chat in allChats {
                self.deleteExpiredMessages(for: chat)
            }
        }
    }
    
    func loadAllChats(for userID: String) -> [Chat] {
        let realm = try! Realm()
        return Array(realm.objects(Chat.self).filter("currentUID == %@", userID))
    }

    func getOrCreateChat(contactID: String, currentUID: String) throws -> Chat {
        let chatID = "\(currentUID)_\(contactID)"
        let realm = try! Realm()
        if let existingChat = realm.object(ofType: Chat.self, forPrimaryKey: chatID) {
            return existingChat
        } else {
            let newChat = Chat(contactID: contactID)
            try realm.write {
                realm.add(newChat)
            }
            return newChat
        }
    }
    
    func fetchChatImagesFromRealm(with contactID: String) -> [UIImage] {
        guard let realm = try? Realm() else { return [] }

        let messages = realm.objects(Message.self).filter(
            "(senderID == %@ OR recipientID == %@) AND imageData != nil",
            contactID, contactID
        )

        return messages.compactMap { message in
            guard let data = message.imageData else { return nil }
            return UIImage(data: data)
        }
    }
    

    
    func deleteMessagesFromChat(forContactID: String) throws {
        let realm = try! Realm()
        guard let chatToDelete = realm.objects(Chat.self).filter("contactID == %@", forContactID).first else { return }
        guard !chatToDelete.isInvalidated else { return }

        try realm.write {
            let messagesCopy = Array(chatToDelete.messages)
            realm.delete(messagesCopy)
            chatToDelete.lastMessageText = nil
        }
    }
    
    func deleteChat(forContactID: String) throws {
        let realm = try! Realm()
        guard let chatToDelete = realm.objects(Chat.self).filter("contactID == %@", forContactID).first else { return }
        guard !chatToDelete.isInvalidated else { return }

        try realm.write {
            let messagesCopy = Array(chatToDelete.messages)
            realm.delete(messagesCopy)
            realm.delete(chatToDelete)
        }
    }
    
    func updateChat(from chatDTO: ChatDTO) throws {
        let realm = try! Realm()
        guard let chat = realm.object(ofType: Chat.self, forPrimaryKey: chatDTO.id) else {
            throw NSError(domain: "LocalChatService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Chat not found"])
        }

        try realm.write {
            chat.lastMessageText = chatDTO.lastMessageText
            chat.lastMessageDate = chatDTO.lastMessageDate
            chat.messages.removeAll()
            chat.messages.append(objectsIn: chatDTO.messages.map { $0.toMessage() })
        }
    }
    
    func deleteAllChats() throws {
        let realm = try! Realm()

        try realm.write {
            let allChats = realm.objects(Chat.self)
            let allMessages = realm.objects(Message.self)
            
            realm.delete(allMessages)
            realm.delete(allChats)
        }
    }
    
    func updateDeleteTimer(for contactID: String, deleteTime: Int) throws {
        guard let currentUID = UserManager.shared.currentUID else {
            throw NSError(domain: "LocalChatService", code: 404, userInfo: [NSLocalizedDescriptionKey: "UserID unavailable"]) }
        
        let realm = try Realm()
        
        guard let chat = realm.object(ofType: Chat.self, forPrimaryKey: "\(currentUID)_\(contactID)") else {
            throw NSError(domain: "LocalChatService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Chat's not found"])
        }
        
        try realm.write {
            chat.deleteTimer = deleteTime
        }
        
        NotificationCenter.default.post(name: .newAutoDeleteTime, object: nil, userInfo: ["deleteTime": deleteTime])
    }
    
    func deleteExpiredMessages(for chat: Chat) {
        let realm = try! Realm()
        let now = Date()

        guard let deleteInterval = chat.deleteTimer else { return }

        let expirationTime: TimeInterval?
        switch deleteInterval {
        case 0: expirationTime = nil
        case 1: expirationTime = 3600
        case 2: expirationTime = 86400
        case 3: expirationTime = 604800
        default: expirationTime = nil
        }

        guard let timeInterval = expirationTime else { return }

        let expiredMessages = chat.messages.filter { message in
            return message.date.addingTimeInterval(timeInterval) <= now
        }

        try? realm.write {
            realm.delete(expiredMessages)
        }
    }
}
 
