//
//  NetworkMessageService.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/1/25.
//

import Foundation
import FirebaseStorage
import CryptoKit
import Firebase

final class NetworkMessageService {
    
    static let shared = NetworkMessageService()
    
    private var messageHandle: DatabaseHandle?
    private var deleteHandel: DatabaseHandle?
    
    private let databaseRef = Database.database().reference()
    
    private init() {}
    
    func listenForMessages(for userID: String, onMessageReceived: @escaping (MessageDTO) -> Void) {
        self.stopListening()
        let encryptor = EncryptionManager(userID: userID)
        
        messageHandle = databaseRef.child("messages").child(userID).observe(.childAdded) { (snapshot: DataSnapshot) in
            guard let messageData = snapshot.value as? [String: Any],
                  let id = messageData["id"] as? String,
                  let senderID = messageData["senderID"] as? String,
                  let recipientID = messageData["recipientID"] as? String,
                  let dateInterval = messageData["date"] as? TimeInterval else {
                return
            }

            ContactManager.shared.fetchContact(byUID: senderID) { result in
                switch result {
                case .success(let contact):
                    let dispatchGroup = DispatchGroup()
                    var decryptedText: String? = nil
                    var decryptedImage: Data? = nil
                    var imageUrl: String? = nil

                    if let encryptedText = messageData["text"] as? String {
                        decryptedText = encryptor.decryptMessage(encryptedText, with: contact.publicKey)
                    }

                    if let storedImageUrl = messageData["imageUrl"] as? String {
                        imageUrl = storedImageUrl
                        dispatchGroup.enter()
                        self.downloadAndDecryptImage(from: storedImageUrl, with: contact.publicKey) { imageData in
                            decryptedImage = imageData
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        
                        let newID = self.generateUniqueID()
                        
                        let message = MessageDTO(
                            id: newID,
                            senderID: senderID,
                            recipientID: recipientID,
                            text: decryptedText,
                            date: Date(timeIntervalSince1970: dateInterval),
                            imageData: decryptedImage,
                            deleteDate: nil
                        )

                        onMessageReceived(message)
                        
                        if let imageUrl = imageUrl {
                            self.deleteImageFromStorage(imageURL: imageUrl)
                        }

                        self.databaseRef.child("messages").child(userID).child(id).removeValue()
                    }
                case .failure(_): break
                }
            }
            
            
        }
    }
    
    func stopListening() {
        if let handle = messageHandle {
            databaseRef.child("messages").removeObserver(withHandle: handle)
            messageHandle = nil
        }
    }
    
    func listenForDeleteRequests(for userID: String) {
        deleteHandel = databaseRef.child("delete_requests").child(userID).observe(.childAdded) { snapshot in
            guard let requestData = snapshot.value as? [String: Any],
                  let chatID = requestData["chatID"] as? String,
                  let senderID = requestData["senderID"] as? String,
                  let messageTimestamp = requestData["messageDate"] as? TimeInterval else {
                return
            }

            let messageDate = Date(timeIntervalSince1970: messageTimestamp)

            do {
                try LocalMessageService.shared.deleteMessage(fromChat: chatID, messageDate: messageDate)
                snapshot.ref.removeValue()
            } catch {
            }
        }
    }
    
    func stopListeningForDeleteRequests() {
        guard let handle = deleteHandel else { return }
        databaseRef.child("delete_requests").removeObserver(withHandle: handle)
        deleteHandel = nil
    }
    
    func sendDeleteRequest(to recipientID: String, message: MessageDTO) {
        let deleteRequest: [String: Any] = [
            "chatID": UserManager.shared.currentUID ?? "",
            "senderID": message.senderID,
            "messageDate": message.date.timeIntervalSince1970
        ]

        databaseRef.child("delete_requests").child(recipientID).childByAutoId().setValue(deleteRequest)
    }
    
    
    
    func sendMessage(_ message: MessageDTO, to contact: ContactDTO, completion: @escaping (Error?) -> Void) {
        guard let currentUID = UserManager.shared.currentUID else { return }
        let encryptor = EncryptionManager(userID: currentUID)
        let dispatchGroup = DispatchGroup()
        var isBlocked = false
        
        dispatchGroup.enter()
        BlockListManager.shared.areUsersBlocked(userID: contact.userID) { value in
            isBlocked = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if isBlocked {
                let error = NSError(domain: "BlockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "You can't send a message to \(contact.username)"])
                completion(error)
                return
            }
            
            var messageData: [String: Any] = [
                "id": message.id,
                "senderID": message.senderID,
                "recipientID": contact.userID,
                "date": message.date.timeIntervalSince1970,
                "deleteData": message.deleteDate ?? ""]
            
            let dispatchGroup = DispatchGroup()
            
            
            if let text = message.text, !text.isEmpty {
                dispatchGroup.enter()
                let textEncrypted = encryptor.encryptMessage(text, with: contact.publicKey)
                messageData["text"] = textEncrypted
                dispatchGroup.leave()
            }
            
            
            if let image = message.imageData {
                dispatchGroup.enter()
                self.uploadEncryptedImage(image, to: contact) { result in
                    switch result {
                    case .success(let imageUrl):
                        messageData["imageUrl"] = imageUrl
                    case .failure(let error):
                        completion(error)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.databaseRef.child("messages").child(contact.userID).child(message.id).setValue(messageData, withCompletionBlock: { error, _ in
                    completion(error)
                })
            }
        }
    }
    
    //MARK: Helpers
    private func deleteImageFromStorage(imageURL: String, completion: ((Error?) -> Void)? = nil) {
        let storageRef = Storage.storage().reference(forURL: imageURL)
        
        storageRef.delete { error in
            if let error = error {
                completion?(error)
            } else {
                completion?(nil)
            }
        }
    }
    
    private func uploadEncryptedImage(_ image: Data, to contact: ContactDTO, completion: @escaping (Result<String, Error>) -> Void) {
        let encryptor = EncryptionManager(userID: UserManager.shared.currentUID ?? "")
        guard let encryptedData = encryptor.encryptData(image, with: contact.publicKey) else {
            completion(.failure(NSError(domain: "EncryptionError", code: 0, userInfo: nil)))
            return
        }

        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).enc")

        storageRef.putData(encryptedData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { url, error in
                    completion(url.map { .success($0.absoluteString) } ?? .failure(error!))
                }
            }
        }
    }

    private func downloadAndDecryptImage(from urlString: String, with peerPublicKey: String, completion: @escaping (Data?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: urlString)
        let encryptor = EncryptionManager(userID: UserManager.shared.currentUID ?? "")

        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            guard let encryptedData = data else {
                completion(nil)
                return
            }

            completion(encryptor.decryptData(encryptedData, with: peerPublicKey))
        }
    }
    
    private func generateUniqueID() -> String {
        let input = "\(UUID().uuidString)-\(Date().timeIntervalSince1970)"
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined().prefix(24).description
    }
}
