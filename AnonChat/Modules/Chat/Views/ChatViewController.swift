//
//  ChatViewController.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/23/25.
//

import UIKit
import Combine
import RealmSwift

class ChatViewController: UIViewController, UITextViewDelegate {
    lazy var userID = contact.userID
    lazy var chatID = viewModel?.chat.id
    
    private var viewModel: ChatViewModel?
    private let coordinator: ChatCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    private let contact: ContactDTO

    private let backgroundImage = UIImageView()
    private let backButton = CustomButton()
    private let username = UILabel()
    private let profileButton = CustomButton()
    private let reportButton = CustomButton()
    private let autoDeleteButton = CustomButton()
    private let subview = UIView()
    private let tableView = MessagesTableView()
    private let textView = CustomTextView()
    
    private var tableViewBottomConstraint: NSLayoutConstraint!
    private var textViewBottomConstraint: NSLayoutConstraint!
    private var rightButtonBottomConstraint: NSLayoutConstraint!
    
    init(viewModel: ChatViewModel, coordinator: ChatCoordinator, contact: ContactDTO) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.contact = contact
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        addKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let viewModel else { return }
        tableView.updateMessages(viewModel.messages)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            tableView.delegate = nil
            tableView.dataSource = nil
            viewModel?.cancelObservingMessages()
            cancellables.removeAll()
            viewModel = nil
        }
    }
    
    deinit {
        cancellables.removeAll()

    }
    
    private func setupUI() {
        view.backgroundColor = .mainBackground
        
        backgroundImage.setBackgroundImage(toView: view)
        backButton.setCircleButton(height: 40, imageName: "arrow.left")
        username.setDefault(text: contact.username, ofSize: 18, weight: .semibold, color: .mainText)
        profileButton.setProfileButton(forUser: contact, height: 40)
        reportButton.setCircleButton(height: 40, imageName: "exclamationmark.shield")
        reportButton.tintColor = .wrongValueTextField
        autoDeleteButton.setCircleButton(height: 40, imageName: "clock")
        tableView.parentView = self
        tableView.configure()
        
        subview.setSubview(toView: view)

        view.addSubview(backButton)
        view.addSubview(profileButton)
        view.addSubview(username)
        view.addSubview(reportButton)
        view.addSubview(autoDeleteButton)
        subview.addSubview(tableView)
        subview.addSubview(textView)
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -10)
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        rightButtonBottomConstraint =  textView.rightButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            
            profileButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            profileButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 15),
            
            username.centerYAnchor.constraint(equalTo: profileButton.centerYAnchor),
            username.leadingAnchor.constraint(equalTo: profileButton.trailingAnchor, constant: 15),
            username.trailingAnchor.constraint(lessThanOrEqualTo: reportButton.leadingAnchor, constant: -15),
            
            autoDeleteButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            autoDeleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            reportButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            reportButton.trailingAnchor.constraint(equalTo: autoDeleteButton.leadingAnchor, constant: -15),
            
            subview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: subview.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            tableViewBottomConstraint,
            
            textView.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            textView.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            textViewBottomConstraint,
            
            textView.leftButton.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            textView.leftButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textView.leftButton.heightAnchor.constraint(equalToConstant: 58),
            textView.leftButton.widthAnchor.constraint(equalToConstant: 58),
            
            textView.rightButton.heightAnchor.constraint(equalToConstant: 58),
            textView.rightButton.widthAnchor.constraint(equalToConstant: 58),
            textView.rightButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            rightButtonBottomConstraint
            
        ])
        
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        textView.isRightButtonActive = viewModel.isContactAvailable
        
        viewModel.$autoDeleteOption
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                ErrorView().show(in: subview, duration: 3, message: "Auto-Delete: \(value.rawValue)")
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        if !viewModel.isContactAvailable {
            ErrorView().show(in: subview, duration: 5,  message: "Contact not available")
        }
        
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self = self else { return }
                self.tableView.updateMessages(messages)
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                guard let text else { return }
                ErrorView().show(in: subview, message: text)
            }
            .store(in: &cancellables)
        
        backButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.back()
        }, for: .touchUpInside)
        
        profileButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showProfile(contact: contact)
        }, for: .touchUpInside)
        
        autoDeleteButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showAutoDelete(vc: self, option: viewModel.autoDeleteOption, contactID: contact.userID)
        }, for: .touchUpInside)
        
        reportButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showReport(vc: self, contact: contact)
        }, for: .touchUpInside)
        
        textView.rightButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            textView.showLoadingOnButton(true)
            let text = self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            viewModel.sendMessage(text: text) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    textView.showLoadingOnButton(false)
                    textView.isButtonActive(false)
                    textView.text = ""
                    textView.delegate?.textViewDidChange?(self.textView)
                case .failure(let error):
                    Logger.log(error.localizedDescription, level: .error)
                    textView.showLoadingOnButton(false)
                    ErrorView().show(in: view, message: error.localizedDescription)
                }
            }
            
        }, for: .touchUpInside)
        
        textView.leftButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showImagePicker(chat: viewModel.chat)
        }, for: .touchUpInside)
        
        textView.didChangeHeight = { [weak self] newHeight in
            guard let self else { return }
            self.tableViewBottomConstraint.constant = -10
            self.view.layoutIfNeeded()
        }
    }
    
    func showImage(image: UIImage?) {
        guard let image = image else { return }
        let imageView = ImageOverView()
        imageView.setup(toView: self)
        imageView.show(withDuration: 0.3, image: image)
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
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let bottomInset = keyboardHeight - 30
            
            textViewBottomConstraint.constant = -bottomInset
            rightButtonBottomConstraint.constant = -bottomInset
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        textViewBottomConstraint.constant = -10
        rightButtonBottomConstraint.constant = -10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.textView.resignFirstResponder()
    }
}
