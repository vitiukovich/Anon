//
//  MainViewController.swift
//  chatApp
//
//  Created by Stanislav Vitiuk on 12/24/24.
//

import UIKit
import Combine

class MainViewController: UIViewController, UISearchBarDelegate {
    let coordinator: MainCoordinator
    let viewModel: MainViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private let backgroundImage = UIImageView()
    private let navigationLabel = UILabel()
    private let profileButton = CustomButton()
    private let searchBar = CustomSearchBar(placeholderTitle: "Search contacts...")
    private let subview = UIView()
    
    private let contactsTableView = ContactsTableView()
    private let chatsTableView = ChatsTableView()

    private let searchLabel = UILabel()
    private let backButton = CustomButton()
    
    init(viewModel: MainViewModel, coordinator: MainCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .newMessageReceived, object: nil)
        cancellables.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchLocalContacts()
        viewModel.fetchLocalChats()
    }
    
    private func setupUI() {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        view.backgroundColor = .mainBackground
        
        backgroundImage.setBackgroundImage(toView: self.view)
        navigationLabel.setDefault(text: "Chats", ofSize: 28, weight: .semibold, color: .mainText)
        profileButton.setProfileButton(forUser: currentUser)
        searchBar.delegate = self
        subview.setSubview(toView: self.view)
        
        searchLabel.setDefault(text: "Search contacts", ofSize: 16, weight: .semibold, color: .mainText)
        backButton.setCircleButton(height: 40, imageName: "arrow.left")
        
        searchLabel.isHidden = true
        backButton.isHidden = true
        
        contactsTableView.parentVC = self
        contactsTableView.configure()
        contactsTableView.frame = subview.bounds
        
        chatsTableView.parentVC = self
        chatsTableView.configure()
        chatsTableView.frame = subview.bounds
        
        subview.addSubview(contactsTableView)
        subview.addSubview(chatsTableView)
        
        view.addSubview(navigationLabel)
        view.addSubview(profileButton)
        view.addSubview(searchLabel)
        view.addSubview(backButton)
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            navigationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            navigationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            profileButton.centerYAnchor.constraint(equalTo: navigationLabel.centerYAnchor),
            
            searchLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            searchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            backButton.centerYAnchor.constraint(equalTo: searchLabel.centerYAnchor),
            
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.73),
            
            contactsTableView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            contactsTableView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            contactsTableView.topAnchor.constraint(equalTo: subview.topAnchor),
            contactsTableView.bottomAnchor.constraint(equalTo: subview.bottomAnchor),
            
            chatsTableView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            chatsTableView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            chatsTableView.topAnchor.constraint(equalTo: subview.topAnchor),
            chatsTableView.bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$chats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chats in
                guard let self = self else { return }
                chatsTableView.data = chats
                chatsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        
        viewModel.$localContacts
            .combineLatest(viewModel.$networkContacts, viewModel.$isSearching)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (local, network, isSearching) in
                guard let self = self else { return }
                contactsTableView.localContacts = local
                contactsTableView.networkContacts = network
                
                contactsTableView.reloadData()
                contactsTableView.updateEmpty(isSearching: isSearching)
                
                updateUI(for: isSearching ? .active : .inactive)
            }
            .store(in: &cancellables)
        
        viewModel.$profileImage
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                profileButton.setImage(UIImage(named: image), for: .normal)
            }
            .store(in: &cancellables)
        
        viewModel.$isNewMassage
            .sink { [weak self] _ in
                guard let self = self else { return }
                viewModel.fetchLocalChats()
                chatsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        backButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            view.endEditing(true)
            contactsTableView.networkContacts.removeAll()
            viewModel.isSearching = false
        }, for: .touchUpInside)
        
        profileButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            coordinator.showProfileSetting()
        }, for: .touchUpInside)
        
    }
    
    //MARK: Delegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.setActiveThinColor(is: true)
        viewModel.isSearching = true
        return true
    }
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.setActiveThinColor(is: false)
        self.searchBar.text = ""
        viewModel.isSearching = false
        viewModel.fetchLocalContacts()
        contactsTableView.reloadData()
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.setShowsCancelButton(false, animated: false)
        
        if !searchText.isEmpty {
            contactsTableView.updateEmpty(isSearching: true)
        } else {
            contactsTableView.updateEmpty(isSearching: false)
        }
        viewModel.searchContacts(query: searchText)
    }
    
    private func updateUI(for state: CustomSearchBar.SearchState) {
        updateViewVisibility(for: state)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func toggleVisibility(_ views: [UIView], hidden: Bool) {
        views.forEach { $0.isHidden = hidden }
    }
    
    private func updateViewVisibility(for state: CustomSearchBar.SearchState) {
        let showViews = state == .active ? [searchLabel, backButton, contactsTableView] : [chatsTableView, navigationLabel, profileButton]
        let hideViews = state == .active ? [chatsTableView, navigationLabel, profileButton] : [searchLabel, backButton, contactsTableView]

        toggleVisibility(showViews, hidden: false)
        toggleVisibility(hideViews, hidden: true)
    }
}
