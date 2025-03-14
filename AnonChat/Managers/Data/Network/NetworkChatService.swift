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
    private var messageRemovingHandle: DatabaseHandle?

    private init(){}
    
    //MARK: Delete Timer
    func sendDeleteTimerSignal(_ userID: String, deleteTime: Int) {
        let chatRef = databaseRef.child("delete_timer_signals").child(userID)
        
        let deleteData: [String: Any] = [
            "userID": UserManager.shared.currentUID ?? "",
            "deleteTime": deleteTime
        ]
        
        chatRef.setValue(deleteData)
    }
    
    func startListeningForDeleteTimer(for userID: String) {
        self.stopListeningForDeleteTimer()
        let chatRef = databaseRef.child("delete_timer_signals").child(userID)

        messageRemovingHandle = chatRef.observe(.value) { snapshot in
            guard let data = snapshot.value as? [String: Any],
                  let senderID = data["userID"] as? String,
                  let deleteTime = data["deleteTime"] as? Int else {
                return
            }

            if senderID != userID {
                do {
                    try LocalChatService.shared.updateDeleteTimer(for: senderID, deleteTime: deleteTime)
                } catch {
                    
                }
                
                NotificationCenter.default.post(name: .newAutoDeleteTime, object: nil, userInfo: ["deleteTime": deleteTime])
                
                chatRef.removeValue()
            }
        }
    }
    
    func stopListeningForDeleteTimer() {
        if let handle = messageRemovingHandle {
            databaseRef.child("delete_timer_signals").removeObserver(withHandle: handle)
            messageRemovingHandle = nil
        }
    }
    
    //MARK: Delete Chat
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
