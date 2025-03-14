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

    }

    func saveMessage(_ message: Message, to chat: Chat) throws {
        let realm = try Realm()
        try realm.write {
            chat.addMessage(message)
        }
    }
}
