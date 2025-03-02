//
//  Chat.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/22/25.
//

import Foundation
import RealmSwift

final class Chat: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var currentUID: String = ""
    @Persisted var contactID: String = ""
    @Persisted var messages: List<Message> = List<Message>()
    @Persisted var lastMessageText: String? = nil
    @Persisted var lastMessageDate: Date?
    @Persisted var hasUnread: Bool = false
    
    convenience init(contactID: String) {
        self.init()
        guard let currentUID = UserManager.shared.currentUID else { return }
        self.id = "\(currentUID)_\(contactID)"
        self.currentUID = currentUID
        self.contactID  = contactID
    }
    
    override init() {
        super.init()
    }
    
    func addIncomingMessage(_ message: Message) {
        if message.text != nil && message.text != "" {
            lastMessageText = message.text
        }
        if message.imageData != nil {
            lastMessageText = "Image"
        }
        lastMessageDate = message.date
        hasUnread = true
        messages.append(message)
    }
    
    func addMessage(_ message: Message) {
        if message.text != nil && message.text != "" {
            lastMessageText = message.text
        }
        if message.imageData != nil {
            lastMessageText = "Image"
        }
        lastMessageDate = message.date
        messages.append(message)
    }
    
    func markAsRead() {
        do {
            let realm = try Realm()
            try realm.write {
                hasUnread = false
            }
        } catch {}
    }
    
    func toDTO() -> ChatDTO {
        ChatDTO(id: id,
                currentUID: currentUID,
                contactID: contactID,
                messages: messages.map{ $0.toDTO() }.sorted { $0.date < $1.date },
                lastMessageText: lastMessageText ?? "",
                lastMessageDate: lastMessageDate ?? Date(),
                hasUnread: hasUnread)
    }
}

struct ChatDTO {
    let id: String
    let currentUID: String
    let contactID: String
    let messages: [MessageDTO]
    let lastMessageText: String
    let lastMessageDate: Date
    let hasUnread: Bool
    
    func toChat() -> Chat {
        let chat = Chat()
        chat.id = self.id
        chat.currentUID = self.currentUID
        chat.contactID  = self.contactID
        chat.lastMessageDate = self.lastMessageDate
        chat.lastMessageText = self.lastMessageText
        chat.hasUnread = self.hasUnread
        chat.messages.append(objectsIn: self.messages.map({$0.toMessage()}))
        return chat
    }
}
