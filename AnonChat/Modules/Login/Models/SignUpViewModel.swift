//
//  SignUpViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/4/25.
//

import UIKit
import Combine
import FirebaseAuth

final class SignUpViewModel {
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    
    @Published var signUpErrorMessage: String? = nil
    @Published var isUsernameAvailable: Bool? = nil
    @Published var isPasswordMatching: Bool? = nil
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $username
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] newUsername in
                guard let self = self, !newUsername.isEmpty else {
                    return
                }
                self.checkUsernameAvailability(completion: { result in
                    switch result {
                    case .success(let value): self.isUsernameAvailable = value
                    case .failure: break
                    }
                })
            }
            .store(in: &cancellables)
    }
    
    func checkUsernameAvailability(completion: @escaping (Result<Bool, Error>) -> ())  {
        guard !username.isEmpty else {
            completion(.failure(NSError(domain: "SignUpError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty username"])))
            return
        }
        UserManager.shared.isUsernameAvailable(username: self.username.lowercased()) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isAvailable): completion(.success(isAvailable))
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    
    func signUp(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !username.isEmpty else {
            signUpErrorMessage = "Enter username"
            completion(.failure(NSError(domain: "SignUpError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty username"])))
            return
        }
        
        guard password == repeatPassword else {
            signUpErrorMessage = "Passwords do not match"
            isPasswordMatching = false
            completion(.failure(NSError(domain: "SignUpError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
            return
        }
        
        isPasswordMatching = true
        
        UserManager.shared.registerUser(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.signUpErrorMessage = nil
                    completion(.success(()))
                case .failure(let error):
                    if (error as NSError).code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        self.signUpErrorMessage = "Username already in use"
                    } else {
                        self.signUpErrorMessage = error.localizedDescription
                    }
                    completion(.failure(error))
                }
            }
        }
    }
}
