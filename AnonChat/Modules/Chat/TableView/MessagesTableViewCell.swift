//
//  MassagesTableViewCell.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(message: MessageDTO, imageTapHandler: @escaping (UIImage) -> Void, deleteMessageHandler: @escaping (MessageDTO) -> Void) {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        guard message.text != nil || message.imageData != nil else { return }
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let button = UIButton()
        button.setImage(UIImage(systemName:"xmark.circle"), for: .normal)
        button.tintColor = .placeholderText
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { _ in
            deleteMessageHandler(message)
        }, for: .touchUpInside)

        
        let isCurrentUser = message.senderID == UserManager.shared.currentUID
        let image = message.imageData != nil ? UIImage(data: message.imageData!) : nil
        let messageView = MessageView(isCurrentUser: isCurrentUser, massage: message.text ?? "", time: message.date, image: image)
        messageView.onImageTap = imageTapHandler

        contentView.addSubview(messageView)
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            messageView.widthAnchor.constraint(greaterThanOrEqualTo: contentView.widthAnchor, multiplier: 0.4),
            
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(equalToConstant: 30),
        ])
        
        if isCurrentUser {
            NSLayoutConstraint.activate([
                messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                messageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60),
                
                button.centerYAnchor.constraint(equalTo: messageView.centerYAnchor),
                button.trailingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -5),
            ])
        } else {
            NSLayoutConstraint.activate([
                messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                messageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60),
                
                button.centerYAnchor.constraint(equalTo: messageView.centerYAnchor),
                button.leadingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: 5),
            ])
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
