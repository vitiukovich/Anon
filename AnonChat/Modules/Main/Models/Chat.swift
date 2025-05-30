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
    @Persisted var deleteTimer: Int? = 0
    
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
            hasUnread = true
            lastMessageDate = message.date
            messages.append(message)
        }
        
        if message.imageData != nil {
            lastMessageText = "Image"
            hasUnread = true
            lastMessageDate = message.date
            messages.append(message)
        }
        
        if message.deleteDate != nil {
            deleteTimer = message.deleteDate
        }
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
        } catch {
            Logger.log("Mark is Read Error: \(error.localizedDescription)", level: .error)
        }
    }
    
    func toDTO() -> ChatDTO {
        ChatDTO(id: id,
                currentUID: currentUID,
                contactID: contactID,
                messages: messages.map{ $0.toDTO() }.sorted { $0.date < $1.date },
                lastMessageText: lastMessageText ?? "",
                lastMessageDate: lastMessageDate ?? Date(),
                hasUnread: hasUnread,
                deleteTimer: deleteTimer)
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
    let deleteTimer: Int?
    
    func toChat() -> Chat {
        let chat = Chat()
        chat.id = self.id
        chat.currentUID = self.currentUID
        chat.contactID  = self.contactID
        chat.lastMessageDate = self.lastMessageDate
        chat.lastMessageText = self.lastMessageText
        chat.hasUnread = self.hasUnread
        chat.deleteTimer = self.deleteTimer
        chat.messages.append(objectsIn: self.messages.map({$0.toMessage()}))
        return chat
    }
}

extension ChatDTO: Hashable {
    static func == (lhs: ChatDTO, rhs: ChatDTO) -> Bool {
        return lhs.contactID == rhs.contactID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
