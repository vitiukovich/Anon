//
//  LoginView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit
import Combine

class LoginView: UIView, UITextFieldDelegate {
    
    private let viewModel: LoginViewModel
    private let coordinator: LoginCoordinator
    private let viewController: LoginViewController
    
    private let loginSubview = UIView()
    private let loginUsername = UITextField()
    private let loginPassword = UITextField()
    private let loginButton = CustomButton()
    
    private let errorView = ErrorView()
    
    private let rememberMeCheckbox = CustomButton()
    private let rememberMeLabel = UILabel()
    private let rememberMeStackView = UIStackView()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: LoginCoordinator, viewController: LoginViewController) {
        self.viewModel = LoginViewModel()
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
    
    private func setupUI() {
        
        loginSubview.clipsToBounds = true
        loginSubview.translatesAutoresizingMaskIntoConstraints = false
        loginUsername.setUsernameStyle()
        loginPassword.setPasswordStyle(isRepeat: false)
        loginButton.setDefaultButton(withTitle: "Login")
        
        rememberMeCheckbox.setCheckBoxButton()
        rememberMeLabel.setDefault(text: "Remember me?", ofSize: 16, weight: .medium, color: .mainText)
        rememberMeStackView.addArrangedSubview(rememberMeCheckbox)
        rememberMeStackView.addArrangedSubview(rememberMeLabel)
        rememberMeStackView.alignment = .center
        rememberMeStackView.axis = .horizontal
        rememberMeStackView.spacing = 10
        rememberMeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(loginUsername)
        self.addSubview(loginPassword)
        self.addSubview(rememberMeStackView)
        self.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginUsername.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            loginUsername.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            loginUsername.topAnchor.constraint(equalTo: self.topAnchor, constant: 35),
            
            loginPassword.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            loginPassword.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            loginPassword.topAnchor.constraint(equalTo: loginUsername.bottomAnchor, constant: 45),
            
            rememberMeStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 45),
            rememberMeStackView.topAnchor.constraint(equalTo: loginPassword.bottomAnchor, constant: 40),
            
            loginButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: rememberMeStackView.bottomAnchor, constant: 45),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.widthAnchor.constraint(equalToConstant: 209),
        ])
        
        loginUsername.delegate = self
        loginPassword.delegate = self
    }
    
    private func bindViewModel() {
        loginUsername.textPublisher
            .assign(to: \.username, on: viewModel)
            .store(in: &cancellables)
        
        loginPassword.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$isLoginSuccessful
            .receive(on: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in
                self?.coordinator.navigateToMainView()
            }
            .store(in: &cancellables)
        
        viewModel.$loginErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                guard let errorMessage = errorMessage else { return }
                errorView.show(in: viewController.view, duration: 10, message: errorMessage)
            }
            .store(in: &cancellables)
        
        rememberMeCheckbox.addAction(UIAction { [weak self] _ in
            self?.viewModel.toggleRememberMe()
        }, for: .touchUpInside)
        
        loginButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.login { result in
                switch result {
                case .success: break
                case .failure(_):
                    self?.loginUsername.isAvailableValue(false)
                    self?.loginPassword.isAvailableValue(false)
                }
            }
        }, for: .touchUpInside)
    }
    
    //MARK: TextField delegate
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
        case loginUsername:
            return loginPassword
        default:
            return nil
        }
    }
}
