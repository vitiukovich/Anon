//
//  ChatsTableView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/24/25.
//

import UIKit

class ChatsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var data: [ChatDTO] = [] {
        didSet {
            self.backgroundView = data.isEmpty ? backgroundTableView : nil
            self.reloadData()
        }
    }
    weak var parentVC: MainViewController?
    
    private let backgroundTableView = BackgroundView()
    
    func configure() {
        self.dataSource = self
        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.rowHeight = 80
        self.backgroundColor = .secondBackground
        self.separatorStyle = .singleLine
        
        backgroundTableView.configure(frame: self.frame)
        backgroundTableView.label.text = "No Chat Available to Display"
        self.backgroundView = data.isEmpty ? backgroundTableView : nil
        
        self.register(ChatsTableViewCell.self, forCellReuseIdentifier: "ChatsCell")
    }
    
    
    func showDeleteOptions(for chat: ChatDTO) {
        guard let parentVC = self.parentVC else { return }
        let firstAction = UIAction { _ in
            parentVC.viewModel.deleteChat(chat, forEveryone: false)
        }
        let secondAction = UIAction { _ in
            parentVC.viewModel.deleteChat(chat, forEveryone: true)
        }
        parentVC.coordinator.removeChat(vc: parentVC, actionForMe: firstAction, forEveryone: secondAction)
    }
    
    //MARK: DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsTableViewCell
        let contactID = data[indexPath.row].contactID
        ContactManager.shared.fetchContact(byUID: contactID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let contact):
                cell.unreadIndicator.isHidden = !self.data[indexPath.row].hasUnread
                cell.username.text = contact.username
                cell.lastMessage.text = self.data[indexPath.row].lastMessageText
                cell.profileImage.setImageWithLabel(imageName: contact.profileImage,
                                                    text: contact.username.first?.uppercased() ?? "")
            case .failure(let error):
                break
            }
            
        }
        return cell
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactID = data[indexPath.row].contactID
        ContactManager.shared.fetchContact(byUID: contactID) { [weak self] result in
            switch result {
            case .success(let contact):
                self?.parentVC?.coordinator.showChat(for: contact)
                tableView.deselectRow(at: indexPath, animated: true)
            case .failure(let error):
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            guard let parentVC = self.parentVC else { return }
            let chat = parentVC.viewModel.chats[indexPath.row]
            showDeleteOptions(for: chat)
            self.reloadData()
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
