//
//  AuthService.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/27/25.
//

import FirebaseAuth

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func loginUser(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let email = "\(username.lowercased())@bbbgggddd.com"
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                if let authError = error as NSError?,
                   let errorCode = AuthErrorCode(rawValue: authError.code) {
                    switch errorCode {
                    case .wrongPassword, .userNotFound:
                        let loginError = NSError(domain: "AuthService",
                                                 code: authError.code,
                                                 userInfo: [NSLocalizedDescriptionKey: "Incorrect login or password"])
                        completion(.failure(loginError))
                        return
                    default:
                        completion(.failure(error))
                    }
                }
            }
            
            guard let userID = result?.user.uid else {
                completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user ID"])))
                return
            }
            completion(.success(userID))
        }
    }

    func registerUser(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let email = "\(username.lowercased())@bbbgggddd.com"
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                if let authError = error as NSError?,
                   let errorCode = AuthErrorCode(rawValue: authError.code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        let loginTakenError = NSError(domain: "AuthService",
                                                      code: authError.code,
                                                      userInfo: [NSLocalizedDescriptionKey: "Username already in use"])
                        completion(.failure(loginTakenError))
                        return
                    default:
                        completion(.failure(error))
                    }
                }
            }
            if let authResult = authResult {
                completion(.success(authResult.user.uid))
            }
        }
    }

    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            return
        }

        user.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
