//
//  ContactTableViewCell.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 12/26/24.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    let profileImage = ProfileImage(height: 50)
    let username = UILabel()
    let status = UILabel()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.imageView.image = nil
        username.text = nil
        status.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .secondBackground
        self.selectionStyle = .none
        
        profileImage.setupLabel()
        profileImage.setShadow(opacity: 0.1, radius: 9)
        profileImage.setBorder(color: .imageBorder, borderWidth: 2)
        username.setDefault(ofSize: 18, weight: .semibold, color: .mainText)
        status.setDefault(ofSize: 16, weight: .light, color: .mainText)
        
        self.addSubview(username)
        self.addSubview(profileImage)
        self.addSubview(status)

        NSLayoutConstraint.activate([
            profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            
            username.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 25),
            username.bottomAnchor.constraint(equalTo: self.centerYAnchor),
            
            status.leadingAnchor.constraint(equalTo: username.leadingAnchor),
            status.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
