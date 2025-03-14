//
//  ChatsTableViewCell.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/24/25.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    let profileImage = ProfileImage(height: 54)
    let username = UILabel()
    let lastMessage = UILabel()
    let unreadIndicator = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .secondBackground
        self.selectionStyle = .none
        
        profileImage.setupLabel()
        profileImage.setShadow(opacity: 0.1, radius: 9)
        profileImage.setBorder(color: .imageBorder, borderWidth: 2)
        username.setDefault(ofSize: 18, weight: .semibold, color: .mainText)
        lastMessage.setDefault(ofSize: 16, weight: .light, color: .placeholder)
        lastMessage.numberOfLines = 1
        lastMessage.textAlignment = .left
        
        unreadIndicator.backgroundColor = .activeButton
        unreadIndicator.layer.cornerRadius = 10
        unreadIndicator.clipsToBounds = true
        unreadIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.setDefault(text: "NEW", ofSize: 10, weight: .bold, color: .white)
        
        self.addSubview(username)
        self.addSubview(profileImage)
        self.addSubview(lastMessage)
        self.addSubview(unreadIndicator)
        
        unreadIndicator.addSubview(label)

        NSLayoutConstraint.activate([
            profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            
            username.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15),
            username.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -2),
            
            lastMessage.leadingAnchor.constraint(equalTo: username.leadingAnchor),
            lastMessage.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 2),
            lastMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -45),
            
            label.topAnchor.constraint(equalTo: unreadIndicator.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: unreadIndicator.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: unreadIndicator.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: unreadIndicator.trailingAnchor, constant: -5),
            
            unreadIndicator.heightAnchor.constraint(equalToConstant: 20),
            unreadIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            unreadIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
