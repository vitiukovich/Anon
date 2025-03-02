//
//  NetworkChatService.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/27/25.
//

import Firebase
import FirebaseStorage


final class NetworkChatService {
    
    static let shared = NetworkChatService()
    private let databaseRef = Database.database().reference()
    private var chatRemovingHandle: DatabaseHandle?

    private init(){}
    
    func sendDeleteChatSignal(_ chat: ChatDTO) {
        let chatRef = databaseRef.child("delete_chat_signals").child(chat.contactID)
        let deleteData: String = chat.currentUID
        chatRef.setValue(deleteData)
    }
    
    func listenForChatDeletions(for userID: String) {
        self.stopListenForChatDeletions()
        let chatRef = databaseRef.child("delete_chat_signals").child(userID)

        chatRemovingHandle = chatRef.observe(.value) { (snapshot: DataSnapshot) in
            guard let contactID = snapshot.value as? String else { return }
            do {
                try ChatManager.shared.deleteMessagesFromChat(forContactID: contactID)
            } catch {}
            chatRef.removeValue()
        }
    }

    func stopListenForChatDeletions() {
        if let handle = chatRemovingHandle {
            databaseRef.child("delete_chat_signals").removeObserver(withHandle: handle)
            chatRemovingHandle = nil
        }
    }
}
