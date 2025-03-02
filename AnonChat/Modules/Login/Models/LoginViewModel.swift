//
//  LoginViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit
import Combine
import FirebaseAuth

final class LoginViewModel {
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isRememberMeSelected: Bool = false
    
    @Published var loginErrorMessage: String? = nil
    @Published var isLoginSuccessful: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func login(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            loginErrorMessage = "Enter login and password!"
            completion(.failure(NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
            return
        }
        
        UserManager.shared.loginUser(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isLoginSuccessful = true
                    self?.loginErrorMessage = nil
                case .failure(let error):
                    if (error as NSError).code == AuthErrorCode.wrongPassword.rawValue ||
                       (error as NSError).code == AuthErrorCode.userNotFound.rawValue {
                        self?.loginErrorMessage = "Incorrect login or password!"
                    } else {
                        self?.loginErrorMessage = error.localizedDescription
                    }
                    completion(.failure(error))
                    self?.isLoginSuccessful = false
                }
            }
        }
    }
    
    func toggleRememberMe() {
        isRememberMeSelected.toggle()
    }
}

