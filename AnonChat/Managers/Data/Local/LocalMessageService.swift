//
//  LocalMessageService.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/1/25.
//

import Foundation
import RealmSwift

final class LocalMessageService {
    
    static let shared = LocalMessageService()
    
    func saveIncomingMessage(_ message: Message, to chat: Chat) throws {
        let realm = try Realm()
        try realm.write {
            chat.addIncomingMessage(message)
        }
        NotificationCenter.default.post(name: .newMessageSaved, object: nil)

    }

    func saveMessage(_ message: Message, to chat: Chat) throws {
        let realm = try Realm()
        try realm.write {
            chat.addMessage(message)
        }
    }
    
    func deleteMessage(fromChat chatID: String, messageDate: Date) throws {
        let realm = try Realm()
        
        guard let chat = realm.object(ofType: Chat.self, forPrimaryKey: chatID),
              !chat.isInvalidated,
              let messageToDelete = chat.messages.filter("date == %@", messageDate).first else {
            return
        }
        
        try realm.write {
            realm.delete(messageToDelete)
            
            if chat.messages.isEmpty {
                chat.lastMessageText = nil
            }
        }

    }
}
