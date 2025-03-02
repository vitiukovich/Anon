//
//  SettingTableView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/28/25.
//

import UIKit

class SettingCell: UITableViewCell {
    
    let titleLabel = UILabel()
    var customSwitch = UISwitch()
    let iconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, textColor: UIColor = .mainText, isIcon: Bool = false, switch: UISwitch? = nil) {
        backgroundColor = .clear
        titleLabel.setDefault(text: title, ofSize: 20, weight: .regular, color: textColor)
        
        if isIcon {
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.image = UIImage(systemName: "chevron.right")
            iconImageView.tintColor = .placeholder
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(iconImageView)
            
            NSLayoutConstraint.activate([
                iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
                iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 35),
                iconImageView.heightAnchor.constraint(equalToConstant: 35),
            ])
        }
        
        if let `switch` = `switch` {
            customSwitch = `switch`
            contentView.addSubview(customSwitch)
            
            NSLayoutConstraint.activate([
                customSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
                customSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
        }

        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

