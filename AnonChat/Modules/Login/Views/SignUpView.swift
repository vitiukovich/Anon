//
//  SignUpView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit
import Combine

class SignUpView: UIView, UITextFieldDelegate {

    private let viewModel: SignUpViewModel
    private let coordinator: LoginCoordinator
    private weak var viewController: LoginViewController?
    
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let repeatPasswordTextField = UITextField()
    private let signUpButton = CustomButton()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: LoginCoordinator, viewController: LoginViewController) {
        self.viewModel = SignUpViewModel()
        self.coordinator = coordinator
        self.viewController = viewController
        super.init(frame: .zero)
        
        setupUI()
        bindViewModel()
        
        self.backgroundColor = nil
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit SignUpView")
        cancellables.removeAll()
    }
    
    private func setupUI() {
        usernameTextField.setUsernameStyle()
        passwordTextField.setPasswordStyle(isRepeat: false)
        repeatPasswordTextField.setPasswordStyle(isRepeat: true)
        signUpButton.setDefaultButton(withTitle: "Sign Up")
        
        self.addSubview(usernameTextField)
        self.addSubview(passwordTextField)
        self.addSubview(repeatPasswordTextField)
        self.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            
            usernameTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            usernameTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            usernameTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 35),
            
            passwordTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            passwordTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 45),
            
            repeatPasswordTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            repeatPasswordTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            repeatPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 45),
            
            signUpButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: repeatPasswordTextField.bottomAnchor, constant: 45),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.widthAnchor.constraint(equalToConstant: 209),
        ])
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
    }
    
    private func bindViewModel() {
        
        usernameTextField.textPublisher
            .assign(to: \.username, on: viewModel)
            .store(in: &cancellables)

        passwordTextField.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)

        repeatPasswordTextField.textPublisher
            .assign(to: \.repeatPassword, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$signUpErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let vc = self?.viewController else { return }
                guard let errorMessage = errorMessage else { return }
                ErrorView().show(in: vc.view, message: errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.$isUsernameAvailable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                guard let value = value else { return }
                usernameTextField.isAvailableValue(value)
            }
            .store(in: &cancellables)
        
        viewModel.$isPasswordMatching
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                guard let value = value else { return }
                passwordTextField.isAvailableValue(value)
                repeatPasswordTextField.isAvailableValue(value)
            }
            .store(in: &cancellables)
        
        signUpButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.signUp { [weak self] result in
                switch result {
                case .success():
                    self?.coordinator.navigateToMainView()
                case .failure(_):
                    break
                }
            }
        }, for: .touchUpInside)
    }
    
    //MARK: TextField delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameTextField {
            let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
            let characterSet = CharacterSet(charactersIn: allowedCharacters)
            return string.rangeOfCharacter(from: characterSet) != nil || string.isEmpty
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = getNextTextField(from: textField) {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    private func getNextTextField(from textField: UITextField) -> UITextField? {
        switch textField {
        case usernameTextField:
            return passwordTextField
        case passwordTextField:
            return repeatPasswordTextField
        default:
            return nil
        }
    }

}
