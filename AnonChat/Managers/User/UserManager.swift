//
//  UserManager.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import Foundation
import Combine

final class UserManager {
    @Published private(set) var currentUser: ContactDTO?
    @Published var profileImage: String = ""
    private(set) var currentUID: String? {
        get { UserDefaults.standard.string(forKey: "currentUID") }
        set { UserDefaults.standard.set(newValue, forKey: "currentUID") }
    }
    
    private var user: ContactDTO? {
        get {
            let username = UserDefaults.standard.string(forKey: "username") ?? ""
            let profileImage = UserDefaults.standard.string(forKey: "profileImage") ?? ""
            let userID = UserDefaults.standard.string(forKey: "currentUID") ?? ""
            let publicKey = UserDefaults.standard.string(forKey: "publicKey") ?? ""
            let status = UserDefaults.standard.string(forKey: "status") ?? ""
            return (ContactDTO(username: username,
                               status: status,
                               profileImage: profileImage,
                               userID: userID,
                               publicKey: publicKey,
                               isContactBlocked: false))
        }
        set {
            UserDefaults.standard.set(newValue?.profileImage, forKey: "profileImage")
            UserDefaults.standard.set(newValue?.username, forKey: "username")
            UserDefaults.standard.set(newValue?.publicKey, forKey: "publicKey")
            UserDefaults.standard.set(newValue?.status, forKey: "status")
            currentUser = user ?? nil
        }
    }

    static let shared = UserManager()
    private let authService = AuthService.shared
    private let userService = UserService.shared

    private init() {
        self.currentUser = user
        self.profileImage = user?.profileImage ?? ""
    }

    func loginUser(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.loginUser(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userID):
                self.userService.fetchCurrentUserData(userID: userID) { result in
                    switch result {
                    case .success(let contact):
                        self.currentUID = userID
                        self.profileImage = contact.profileImage
                        self.user = contact
                        self.checkKey(for: userID)
                        MessageManager.shared.startListeningForMessages(for: userID)
                        NetworkMessageService.shared.listenForDeleteRequests(for: userID)
                        ChatManager.shared.startListeningForDeleteChatSignal(for: userID)
                        NetworkChatService.shared.startListeningForDeleteTimer(for: userID)
                        self.userService.updateFCMToken()
                        self.userService.updateCurrentUserData(userID: userID, status: "Available") { result in
                            switch result {
                            case .success():
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    func registerUser(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authService.registerUser(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userID):
                self.userService.createUser(userID: userID, username: username) { result in
                    switch result {
                    case .success:
                            self.loginUser(username: username, password: password, completion: { result in
                                switch result {
                                case .success():
                                    completion(.success(()))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            })
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUID = self.currentUID else { return }
        userService.updateCurrentUserData(userID: currentUID, status: "Out of system") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                authService.logoutUser { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        self.userService.resetRealm()
                        self.user = nil
                        self.currentUID = nil
                        
                        UserDefaults.standard.removeObject(forKey: "currentUID")
                        UserDefaults.standard.removeObject(forKey: "profileImage")
                        UserDefaults.standard.removeObject(forKey: "username")
                        UserDefaults.standard.removeObject(forKey: "publicKey")
                        UserDefaults.standard.removeObject(forKey: "status")
                        self.profileImage = ""
                        MessageManager.shared.stopListeningForMessages()
                        NetworkMessageService.shared.stopListeningForDeleteRequests()
                        ChatManager.shared.stopListeningForDeleteChatSignal()
                        NetworkChatService.shared.stopListeningForDeleteTimer()
                        
                        completion(.success(()))
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
                
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateCurrentUserData(username: String? = nil, status: String? = nil, profileImage: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        if let newImage = profileImage {
            self.profileImage = newImage
        }
        guard let currentUID = currentUID else { return }
        userService.updateCurrentUserData(userID: currentUID, username: username, status: status, profileImage: profileImage, completion: completion)
    }
    
    func isUsernameAvailable(username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        userService.isUsernameAvailable(username: username, completion: completion)
    }
    
    private func checkKey(for userID: String) {
        let encryptionManager = EncryptionManager(userID: userID)
        encryptionManager.checkAndUploadKey { result in
            switch result {
            case .success():
                break
            case .failure(_):
                break
            }
        }
    }
}
