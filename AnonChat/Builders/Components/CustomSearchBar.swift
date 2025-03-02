//
//  SearchBar.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit

class CustomSearchBar: UISearchBar {
    
    enum SearchState {
        case active
        case inactive
    }

    private let placeholderText: String
    private let iconImageView = UIImageView(image: UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate))
    
    init(placeholderTitle text: String) {
        self.placeholderText = text
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup(){
        
        self.layer.cornerRadius = 29
        self.backgroundColor = UIColor.secondBackground
        self.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        self.backgroundImage = UIImage()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.setPlaceholder(text: placeholderText, color: .placeholder)
            textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            textField.textColor = .mainText
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            iconImageView.tintColor = .lightGray
            iconImageView.frame = CGRect(x: 15, y: 0, width: 20, height: 20)
            paddingView.addSubview(iconImageView)
            textField.leftView = paddingView
            textField.leftViewMode = .always
            textField.clearButtonMode = .never
            
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: self.topAnchor),
                textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                textField.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                textField.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 58)
        ])
    }
    
    
    func setActiveThinColor(is value: Bool) {
        if value {
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                self.iconImageView.tintColor = .activeButton
                self.iconImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        } else {
            UIView.animate(withDuration: 0.3) {
                self.iconImageView.tintColor = .placeholder
                self.iconImageView.transform = CGAffineTransform.identity
            }
            
        }
    }
    
    
    
}
