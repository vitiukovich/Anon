//
//  Message.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/23/25.
//

import CryptoKit
import RealmSwift
import UIKit

final class Message: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var senderID: String = ""
    @Persisted var recipientID: String = ""
    @Persisted var text: String? = nil
    @Persisted var date: Date = Date()
    @Persisted var imageData: Data? = nil
    @Persisted var deleteDate: Int? = nil
    
    convenience init(senderID: String,
                     recipientID: String,
                     text: String? = nil,
                     image: UIImage? = nil,
                     file: Data? = nil,
                     fileName: String? = nil,
                     deleteDate: Int? = nil) {
        
        self.init()
        self.id = generateUniqueID()
        self.senderID = senderID
        self.recipientID = recipientID
        self.text = text
        self.deleteDate = deleteDate
        self.date = Date()
        if let image = image {
            self.imageData = image.jpegData(compressionQuality: 0.8)
        }
    }
    
    convenience init(id: String,
                     senderID: String,
                     recipientID: String,
                     text: String?,
                     date: Date,
                     imageData: Data?,
                     deleteDate: Int?) {
        self.init()
        self.id = id
        self.senderID = senderID
        self.recipientID = recipientID
        self.text = text
        self.date = date
        self.deleteDate = deleteDate
        self.imageData = imageData
        self.deleteDate = deleteDate
    }
    
    override init() {
        super.init()
    }
    
    func toDTO() -> MessageDTO {
        return MessageDTO(
            id: id,
            senderID: senderID,
            recipientID: recipientID,
            text: text,
            date: date,
            imageData: imageData,
            deleteDate: deleteDate
        )
    }
    
    func generateUniqueID() -> String {
        let input = "\(UUID().uuidString)-\(Date().timeIntervalSince1970)"
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined().prefix(24).description
    }
}
            

struct MessageDTO: Hashable {
    let id: String
    let senderID: String
    let recipientID: String
    let text: String?
    let date: Date
    let imageData: Data?
    let deleteDate: Int?
    
    init(id: String,
         senderID: String,
         recipientID: String,
         text: String?,
         date: Date,
         imageData: Data?,
         deleteDate: Int?) {
        self.id = id
        self.senderID = senderID
        self.recipientID = recipientID
        self.text = text
        self.date = date
        self.imageData = imageData
        self.deleteDate = deleteDate
    }
    
    static func == (lhs: MessageDTO, rhs: MessageDTO) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func toMessage() -> Message {
        Message(id: id,
                senderID: senderID,
                recipientID: recipientID,
                text: text,
                date: date,
                imageData: imageData,
                deleteDate: deleteDate
        )
    }
}
