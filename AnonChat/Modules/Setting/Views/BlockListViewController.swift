//
//  BlockListViewController.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/2/25.
//

import UIKit

final class BlockListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let coordinator: SettingCoordinator
    private let blockedContacts: [ContactDTO]
    private let openProfile: (ContactDTO) -> ()
    private let cancelButton = CustomButton()
    private let subview = UIView()
    private let tableView = UITableView()
    private let backgroundTableView = BackgroundView()
    
    
    init(_ contacts: [ContactDTO], coordinator: SettingCoordinator, openProfile: @escaping (ContactDTO) -> ()){
        self.blockedContacts = contacts
        self.coordinator = coordinator
        self.openProfile = openProfile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .darkenedView
            self.subview.transform = .identity
            self.cancelButton.transform = .identity
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        cancelButton.setCircleButton(height: 40, imageName: "xmark")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BlockListTableViewCell.self, forCellReuseIdentifier: "BlockListCell")
        tableView.allowsSelection = true
        
        tableView.rowHeight = 80
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundTableView.label.text  = "You don't have any blocked contacts"
        
        view.addSubview(cancelButton)
        subview.setSubview(toView: view)
        subview.addSubview(tableView)

        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.topAnchor.constraint(equalTo:   cancelButton.bottomAnchor, constant: 25),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: subview.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
        
        backgroundTableView.configure(frame: tableView.bounds)
        tableView.backgroundView = blockedContacts.isEmpty ? backgroundTableView : nil
    }
    
    func bindActions() {
        cancelButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.dismiss()
        }, for: .touchUpInside)
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.subview.transform = CGAffineTransform(translationX: 0, y: 400)
            self.cancelButton.transform = CGAffineTransform(translationX: 0, y: 400)
            self.view.backgroundColor = .clear
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockListCell", for: indexPath) as! BlockListTableViewCell
        let contact = blockedContacts[indexPath.row]

        cell.username.text = contact.username
        cell.status.text = contact.status
        let firstLetter = contact.username.first?.uppercased() ?? ""
        cell.profileImage.setImageWithLabel(imageName: contact.profileImage, text: firstLetter)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openProfile(blockedContacts[indexPath.row])
        dismiss()
    }
}
