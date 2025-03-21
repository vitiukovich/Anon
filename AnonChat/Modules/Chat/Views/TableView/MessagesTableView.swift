//
//  MessagesTableView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import UIKit

class MessagesTableView: UITableView, UITableViewDelegate {

    enum Section {
        case main
    }
    
    weak var parentView: ChatViewController?
    
    private let backgroundTableView = BackgroundView()
    private var diffableDataSource: UITableViewDiffableDataSource<Section, MessageDTO>!
    
    func configure() {
        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = nil
        self.separatorStyle = .none
        
        self.transform = CGAffineTransform(rotationAngle: .pi)
        
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 78
        
        backgroundTableView.configure(frame: self.frame)
        backgroundTableView.transform = CGAffineTransform(rotationAngle: .pi)
        backgroundTableView.label.text = "No Messages"
        backgroundView = backgroundTableView
        
        self.register(MessagesTableViewCell.self, forCellReuseIdentifier: "MessagesCell")

        diffableDataSource = UITableViewDiffableDataSource<Section, MessageDTO>(tableView: self) { tableView, indexPath, message in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath) as! MessagesTableViewCell
            cell.transform = CGAffineTransform(rotationAngle: .pi)
            cell.configure(message: message, imageTapHandler: { [weak self] image in
                guard let self = self, let parentView = parentView else { return }
                parentView.showImage(image: image)
            }, deleteMessageHandler: { [weak self] message in
                guard let self,
                      let contactID = parentView?.userID,
                      let chatID = parentView?.chatID else { return }
                MessageManager.shared.deleteMessage(message, fromChat: chatID, contactID: contactID)
                
            })
            return cell
        }
        
        self.dataSource = diffableDataSource
    }
    
    func updateMessages(_ messages: [MessageDTO]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MessageDTO>()
        snapshot.appendSections([.main])
        snapshot.appendItems(messages, toSection: .main)
        
        DispatchQueue.main.async {
            guard let diffableDataSource = self.diffableDataSource else { return }
            diffableDataSource.apply(snapshot, animatingDifferences: true) {
                self.scrollToBottom()
            }
        }
        
        backgroundView?.isHidden = !messages.isEmpty
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let rows = self.numberOfRows(inSection: 0)
            guard rows > 0 else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    //MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
