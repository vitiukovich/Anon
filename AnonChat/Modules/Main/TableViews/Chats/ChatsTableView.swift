//
//  ChatsTableView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/24/25.
//

import UIKit

class ChatsTableView: UITableView, UITableViewDelegate {
    
    enum Section {
        case main
    }
    
     private var diffableDataSource: UITableViewDiffableDataSource<Section, ChatDTO>!

    weak var parentVC: MainViewController?
    
    private let backgroundTableView = BackgroundView()
    
    func configure() {
        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.rowHeight = 80
        self.backgroundColor = .secondBackground
        self.separatorStyle = .singleLine
        
        backgroundTableView.configure(frame: self.frame)
        backgroundTableView.label.text = "No Chat Available to Display"
        
        self.register(ChatsTableViewCell.self, forCellReuseIdentifier: "ChatsCell")
        
        diffableDataSource = UITableViewDiffableDataSource<Section, ChatDTO>(tableView: self) { tableView, indexPath, chat in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsTableViewCell
            let contactID = chat.contactID
            
            ContactManager.shared.fetchContact(byUID: contactID) { result in
                switch result {
                case .success(let contact):
                    DispatchQueue.main.async {
                        
                        
                        cell.profileImage.imageView.image = nil
                        cell.username.text = nil
                        cell.lastMessage.text = nil
                        cell.unreadIndicator.isHidden = !chat.hasUnread
                        cell.username.text = contact.username
                        cell.lastMessage.text = chat.lastMessageText
                        cell.profileImage.setImageWithLabel(imageName: contact.profileImage,
                                                            text: contact.username.first?.uppercased() ?? "")
                    }
                case .failure:
                    break
                }
            }
            return cell
        }
        
        
        self.dataSource = diffableDataSource
        
    }
    
    func updateChats(_ chats: [ChatDTO]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChatDTO>()
        snapshot.appendSections([.main])
        snapshot.appendItems(chats, toSection: .main)
        
        DispatchQueue.main.async {
            self.diffableDataSource.apply(snapshot, animatingDifferences: true) {
                self.reloadVisibleCells()
            }
        }
        
        self.backgroundView = chats.isEmpty ? self.backgroundTableView : nil
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
    
    private func reloadVisibleCells() {
        let visibleIndexPaths = self.indexPathsForVisibleRows ?? []
        for indexPath in visibleIndexPaths {
            guard let chat = diffableDataSource.itemIdentifier(for: indexPath),
                  let cell = self.cellForRow(at: indexPath) as? ChatsTableViewCell else { continue }
            
            ContactManager.shared.fetchContact(byUID: chat.contactID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let contact):
                        cell.username.text = contact.username
                        cell.lastMessage.text = chat.lastMessageText
                        cell.unreadIndicator.isHidden = !chat.hasUnread
                        cell.profileImage.setImageWithLabel(imageName: contact.profileImage,
                                                            text: contact.username.first?.uppercased() ?? "")
                    case .failure:
                        break
                    }
                }
            }
        }
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contactID = diffableDataSource.itemIdentifier(for: indexPath)?.contactID {
            ContactManager.shared.fetchContact(byUID: contactID) { [weak self] result in
                switch result {
                case .success(let contact):
                    self?.parentVC?.coordinator.showChat(for: contact)
                    tableView.deselectRow(at: indexPath, animated: true)
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            guard let chat = diffableDataSource.itemIdentifier(for: indexPath) else { return }
            showDeleteOptions(for: chat)
            self.reloadData()
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
