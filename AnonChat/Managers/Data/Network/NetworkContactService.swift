//
//  UserAuth.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 12/27/24.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

final class NetworkContactService {
    static let shared = NetworkContactService()
    private init() {}

    private let db = Firestore.firestore()
    
    // MARK: - Search Contacts
    func searchContacts(query: String, completion: @escaping (Result<[ContactDTO], Error>) -> Void) {
        db.collection("users")
            .whereField("searchTokens", arrayContains: query.lowercased())
            .limit(to: 30)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion(.success([]))
                    return
                }

                let dispatchGroup = DispatchGroup()
                var contacts: [ContactDTO] = []
                
                for document in documents {
                    dispatchGroup.enter()

                    self.parseContact(from: document) { contact in
                        if let contact = contact {
                            contacts.append(contact)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(contacts))
                }
            }
    }

    
    // MARK: - Fetch Contact by UID
    func fetchContact(byUID userID: String, completion: @escaping (Result<ContactDTO, Error>) -> Void) {
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = snapshot, document.exists else {
                let error = NSError(domain: "NetworkManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Contact not found."])
                completion(.failure(error))
                return
            }
            
            self.parseContact(from: document) { result in
                if let contact = result {
                    completion(.success(contact))
                } else {
                    completion(.failure(NSError(domain: "NetworkManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Contact not found."])))
                }
            }
            
        }
    }
    
    // MARK: - Private Helpers
    private func parseContact(from document: QueryDocumentSnapshot, completion: @escaping (ContactDTO?) -> Void){
        let data = document.data()
        guard let username = data["username"] as? String,
              let status = data["status"] as? String,
              let profileImage = data["profileImage"] as? String,
              let publicKey = data["publicKey"] as? String else {
            completion(nil)
            return
        }
        
        BlockListManager.shared.isUserBlocked(userID: document.documentID) { result in
            let contact = ContactDTO(username: username,
                                     status: status,
                                     profileImage: profileImage,
                                     userID: document.documentID,
                                     publicKey: publicKey,
                                     isContactBlocked: result)
            completion(contact)
        }
    }
    
    private func parseContact(from document: DocumentSnapshot, completion: @escaping (ContactDTO?) -> Void) {
        guard let data = document.data(),
              let username = data["username"] as? String,
              let status = data["status"] as? String,
              let profileImage = data["profileImage"] as? String,
              let publicKey = data["publicKey"] as? String else {
            completion(nil)
            return
        }
        BlockListManager.shared.isUserBlocked(userID: document.documentID) { result in
            let contact = ContactDTO(username: username,
                                     status: status,
                                     profileImage: profileImage,
                                     userID: document.documentID,
                                     publicKey: publicKey,
                                     isContactBlocked: result)
            completion(contact)
        }
        
        
    }
    
    
}
