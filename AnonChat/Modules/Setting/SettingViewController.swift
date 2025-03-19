//
//  SettingViewController.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/10/25.
//

import UIKit
import Combine

class SettingViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    private let coordinator: SettingCoordinator
    private let viewModel: SettingViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let currentUser = UserManager.shared.currentUser
    
    private let backgroundImage = UIImageView()
    private let profileLabel = UILabel()
    private let backButton = CustomButton()
    private let logoutButton = CustomButton()
    private let profileImage = ProfileImage(height: 134)
    private let imagePickerButton = UIButton()
    private let usernameLabel = UILabel()
    private let statusLabel = UILabel()
    private let subview = UIView()
    private let tableView = UITableView()
    
    private let notificationsSwitch = UISwitch()
    private let darkThemeSwitch = UISwitch()
    
    init(viewModel: SettingViewModel, coordinator: SettingCoordinator) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()

    }
    
    private func setupUI() {
        view.backgroundColor = .mainBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.rowHeight = 70
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImage.setBackgroundImage(toView: self.view)
        profileLabel.setDefault(text: "Profile setting", ofSize: 16, weight: .semibold, color: .mainText)
        backButton.setCircleButton(height: 40, imageName: "arrow.left")
        logoutButton.setCircleButton(height: 40, imageName: "rectangle.portrait.and.arrow.forward")
        logoutButton.tintColor = .wrongValueTextField
        profileImage.setShadow(opacity: 0.1, radius: 9)
        profileImage.setBorder(color: .imageBorder, borderWidth: 7)
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.setDefault(text: currentUser?.username, ofSize: 24, weight: .semibold, color: .mainText)
        
        
        notificationsSwitch.onTintColor = .activeButton
        notificationsSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        darkThemeSwitch.onTintColor = .activeButton
        darkThemeSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileLabel)
        view.addSubview(backButton)
        view.addSubview(logoutButton)
        view.addSubview(profileImage)
        view.addSubview(imagePickerButton)
        view.addSubview(usernameLabel)
        subview.setSubview(toView: view)
        subview.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            profileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 30),
            
            imagePickerButton.topAnchor.constraint(equalTo: profileImage.topAnchor),
            imagePickerButton.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            imagePickerButton.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            imagePickerButton.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
            
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 30),
            
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 45),
            
            tableView.topAnchor.constraint(equalTo: subview.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
        
    }
    
    private func bindViewModel(){
        viewModel.$profileImage
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self else { return }
                profileImage.setImage(imageName: image)
            }
            .store(in: &cancellables)
        
        viewModel.$alertMessage
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                guard let text = text else { return }
                ErrorView().show(in: self.view, message: text)
            }
            .store(in: &cancellables)
        
        backButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.back()
        }, for: .touchUpInside)
        
        logoutButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showLogOutAlert(vc: self, action: UIAction { [weak self] _ in
                guard let self = self else { return }
                viewModel.logout()
            })
        }, for: .touchUpInside)
        
        imagePickerButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.navigateToImagePicker()
        }, for: .touchUpInside)
        
        notificationsSwitch.isOn = viewModel.isNotificationsOn
        notificationsSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.notificationToggle(notificationsSwitch.isOn)
        }, for: .valueChanged)
        
        darkThemeSwitch.isOn = viewModel.isDarkModeOn
        darkThemeSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.darkModeToggle(darkThemeSwitch.isOn)
        }, for: .valueChanged)
    }
    
    
    //MARK: TableViewDataSorce
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        
        switch indexPath.section {
        case 0:
            cell.configure(title: "Notifications", switch: notificationsSwitch)
        case 1:
            cell.configure(title: "Dark Theme", switch: darkThemeSwitch)
        case 2:
            cell.configure(title: "Blocked Users", isIcon: true)
        case 3:
            cell.configure(title: "Support Chat", textColor: .rightValueTextField , isIcon: true)
        case 4:
            cell.configure(title: "Contact Us", textColor: .rightValueTextField, isIcon: true)
        case 5:
            cell.configure(title: "Delete All Data", textColor: .wrongValueTextField, isIcon: true)
        case 6:
            cell.configure(title: "Delete Account", textColor: .wrongValueTextField, isIcon: true)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 2:
            viewModel.showBlockedUsers()
        case 3:
            coordinator.showSupportChat()
        case 4:
            coordinator.showContactUs(vc: self)
        case 5:
            coordinator.showClearDeviceConfirmation(vc: self, action: UIAction { [weak self] _ in
                guard let self else { return }
                viewModel.clearDeviceData()
            })
        case 6:
            coordinator.showDeleteAccountConfirmation(vc: self, action: UIAction { [weak self] _ in
                guard let self else { return }
                viewModel.deleteAccount()
            })
        default:
            break
        }
    }
}
