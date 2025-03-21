//
//  LoginViewController.swift
//  chatApp
//
//  Created by Stanislav Vitiuk on 12/22/24.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    
    private var loginView: LoginView?
    private var signUpView: SignUpView?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var subviewTopConstraint: NSLayoutConstraint!
    
    private let coordinator: LoginCoordinator
    
    private let backgroundImage = UIImageView()
    private let welcomeLabel = UILabel()
    private let subview = UIView()
    private let segmentedControl = CustomSegmentedControl(width: 326)

    init(coordinator: LoginCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit LoginViewController")
        cancellables.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView = LoginView(coordinator: coordinator, viewController: self)
        signUpView = SignUpView(coordinator: coordinator, viewController: self)
        
        setupUI()
        addKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: "EULAAccepted") {
            let EULAViewController = EULAViewController()
            EULAViewController.modalPresentationStyle = .fullScreen
            present(EULAViewController, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let index = navigationController?.viewControllers.firstIndex(of: self) {
            navigationController?.viewControllers.remove(at: index)
        }
    }
    
    private func setupUI() {
        guard let loginView, let signUpView else { return }
        
        view.backgroundColor = .mainBackground
        
        backgroundImage.setBackgroundImage(toView: self.view)
        welcomeLabel.setDefault(text: "Welcome!", ofSize: 28, weight: .semibold, color: .mainText)
        subview.setSubview(toView: self.view)
        segmentedControl.setTitles(firstTitle: "Login", secondTitle: "Sign Up")
        segmentedControl.setActions { [weak self] in
            self?.toggleViews(showing: loginView, hiding: signUpView)
        } secondClosure: { [weak self] in
            self?.toggleViews(showing: signUpView, hiding: loginView)
        }


        view.addSubview(welcomeLabel)
        subview.addSubview(segmentedControl)
        subview.addSubview(loginView)
        subview.addSubview(signUpView)
        
        subviewTopConstraint = subview.topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 175)
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subviewTopConstraint,
            
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 65),
            
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.topAnchor.constraint(equalTo: subview.topAnchor, constant: 28),
            
            loginView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            signUpView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            signUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            signUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        loginView.alpha = 1
        loginView.isHidden = false
        
        signUpView.alpha = 0
        signUpView.isHidden = true
        
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.keyboardWillShow(notification)
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.keyboardWillHide(notification)
            }
            .store(in: &cancellables)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
            subviewTopConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.welcomeLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        subviewTopConstraint.constant = 175
        
        UIView.animate(withDuration: 0.3) {
            self.welcomeLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    
    private func toggleViews(showing: UIView, hiding: UIView){
        UIView.animate(withDuration: 0.2) {
            hiding.alpha = 0
        } completion: { _ in
            hiding.isHidden = true
            showing.isHidden = false
            UIView.animate(withDuration: 0.2) {
                showing.alpha = 1
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

