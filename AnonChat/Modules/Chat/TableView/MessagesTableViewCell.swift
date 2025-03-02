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
    
    func configure(message: MessageDTO, imageTapHandler: @escaping (UIImage) -> Void) {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let isCurrentUser = message.senderID == UserManager.shared.currentUID
        let image = message.imageData != nil ? UIImage(data: message.imageData!) : nil
        let messageView = MessageView(isCurrentUser: isCurrentUser, massage: message.text ?? "", time: message.date, image: image)
        messageView.onImageTap = imageTapHandler
        
        contentView.addSubview(messageView)
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            messageView.widthAnchor.constraint(greaterThanOrEqualTo: contentView.widthAnchor, multiplier: 0.4)
        ])
        
        if isCurrentUser {
            NSLayoutConstraint.activate([
                messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                messageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60)
            ])
        } else {
            NSLayoutConstraint.activate([
                messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                messageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60)
            ])
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
