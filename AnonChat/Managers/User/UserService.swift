//
//  UserService.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/27/25.
//

import FirebaseFirestore
import FirebaseMessaging
import RealmSwift

final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private init() {}

    func fetchCurrentUserData(userID: String, completion: @escaping (Result<ContactDTO, Error>) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document else {
                completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document is nil"])))
                return
            }

            if !document.exists {
                completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                return
            }

            guard let data = document.data() else {
                completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document data is nil"])))
                return
            }

            guard document.exists,
                  let username = data["username"] as? String,
                  let status = data["status"] as? String,
                  let profileImage = data["profileImage"] as? String,
                  let publicKey = data["publicKey"] as? String else {
                completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data"])))
                return
            }

            let contact = ContactDTO(username: username, status: status, profileImage: profileImage, userID: userID, publicKey: publicKey, isContactBlocked: false)
            completion(.success(contact))
        }
    }
    
    func createUser(userID: String, username: String, fcmToken: String = "", status: String = "Available", profileImage: String = "",
                    completion: @escaping (Result<Void, Error>) -> Void) {
        let userData: [String: Any] = [
            "username": username,
            "lowercasedUsername": username.lowercased(),
            "status": status,
            "profileImage": profileImage,
            "searchTokens": generateSearchTokens(for: username),
            "fcmToken": fcmToken,
            "publicKey" : ""
        ]
        
        db.collection("users").document(userID).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func updateCurrentUserData(userID: String, username: String? = nil, status: String? = nil, fcmToken: String? = nil,
                               profileImage: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        var updatedData: [String: Any] = [:]

        if let username = username {
            updatedData["username"] = username
            updatedData["lowercasedUsername"] = username.lowercased()
            updatedData["searchTokens"] = generateSearchTokens(for: username)
        }
        if let status = status {
            updatedData["status"] = status
        }
        if let profileImage = profileImage {
            updatedData["profileImage"] = profileImage
            UserDefaults.standard.set(profileImage, forKey: "profileImage")
        }
        if let fcmToken = fcmToken {
            updatedData["fcmToken"] = fcmToken
        }

        db.collection("users").document(userID).updateData(updatedData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteCurrentUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = UserManager.shared.currentUID else { return }
        
        var updatedData: [String: Any] = [:]
            updatedData["username"] = "Deleted"
            updatedData["lowercasedUsername"] = ""
            updatedData["searchTokens"] = ""
            updatedData["status"] = "Deleted"
            updatedData["profileImage"] = ""
            updatedData["fcmToken"] = ""

        db.collection("users").document(uid).updateData(updatedData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateFCMToken() {
        Messaging.messaging().token { token, error in
            if error != nil {
                return
            }
            
            guard let token = token else {
                return
            }
            
            if let currentUID = UserManager.shared.currentUID {
                UserService.shared.updateCurrentUserData(userID: currentUID, fcmToken: token, completion: { result in
                    switch result {
                    case .success: break
                    case .failure(_): break
                    }
                })
            }
        }
    }

    func isUsernameAvailable(username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        db.collection("users")
            .whereField("lowercasedUsername", isEqualTo: username.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let isAvailable = snapshot?.documents.isEmpty == true
                completion(.success(isAvailable))
            }
    }

    private func generateSearchTokens(for text: String) -> [String] {
        var tokens: [String] = []
        for i in 1...text.count {
            let prefix = String(text.prefix(i)).lowercased()
            tokens.append(prefix)
        }
        return tokens
    }
    
    func resetRealm() {
        do {
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            for url in realmURLs {
                try FileManager.default.removeItem(at: url)
            }
        } catch { }
    }
}
