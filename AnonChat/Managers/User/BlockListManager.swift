//
//  BlockListManager.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/1/25.
//

import Foundation
import Firebase

final class BlockListManager {
    static let shared = BlockListManager()
    private let databaseRef = Database.database().reference()

    private init() {}
    
    func blockUser(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUID = UserManager.shared.currentUID else { return }
        let blockRef = Database.database().reference().child("blocked_users").child(currentUID)
        
        blockRef.child(userID).setValue(true) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func unblockUser(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUID = UserManager.shared.currentUID else { return }
        let blockRef = Database.database().reference().child("blocked_users").child(currentUID)
        
        blockRef.child(userID).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func isUserBlocked(userID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUID = UserManager.shared.currentUID else {
            completion(false)
            return
        }

        let blockRef = Database.database().reference()
            .child("blocked_users")
            .child(currentUID)
            .child(userID)

        blockRef.observeSingleEvent(of: .value) { snapshot in
            let isBlocked = snapshot.exists()
            completion(isBlocked)
        }
    }
    
    func areUsersBlocked(userID: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("blocked_users")
        let group = DispatchGroup()
        guard let currentUID = UserManager.shared.currentUID else { return }

        var isUser1BlockedByUser2 = false
        var isUser2BlockedByUser1 = false

        group.enter()
        ref.child(userID).child(currentUID).observeSingleEvent(of: .value) { snapshot in
            isUser2BlockedByUser1 = snapshot.exists()
            group.leave()
        }

        group.enter()
        ref.child(currentUID).child(userID).observeSingleEvent(of: .value) { snapshot in
            isUser1BlockedByUser2 = snapshot.exists()
            group.leave()
        }

        group.notify(queue: .main) {
            let blocked = isUser1BlockedByUser2 || isUser2BlockedByUser1
            completion(blocked)
        }
    }
    
    func getBlockedContacts(completion: @escaping (Result<[ContactDTO], Error>) -> Void) {
        fetchBlockedUserIDs { result in
            switch result {
            case .success(let userIDs):
                let dispatchGroup = DispatchGroup()
                var contacts: [ContactDTO] = []
                userIDs.forEach { uid in
                    dispatchGroup.enter()
                    ContactManager.shared.fetchContact(byUID: uid) { result in
                        defer { dispatchGroup.leave() }
                        switch result {
                        case .success(let contact):
                            contacts.append(contact)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) { completion(.success(contacts)) }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //MARK: Helpers 
    private func fetchBlockedUserIDs(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let currentUID = UserManager.shared.currentUID else {
            completion(.failure(NSError(domain: "UserIDError", code: -1, userInfo: nil)))
            return
        }

        let blockedRef = Database.database().reference()
            .child("blocked_users")
            .child(currentUID)

        blockedRef.observeSingleEvent(of: .value) { snapshot in
            guard let blockedDict = snapshot.value as? [String: Bool] else {
                completion(.success([]))
                return
            }

            let blockedUserIDs = Array(blockedDict.keys)
            completion(.success(blockedUserIDs))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
}
