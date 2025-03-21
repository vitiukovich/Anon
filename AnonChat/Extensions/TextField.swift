//
//  Extensions.swift
//  chatApp
//
//  Created by Stanislav Vitiuk on 12/22/24.
//

import UIKit
import Combine


extension UITextField {
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
    
    func applyDefaultStyle() {
        self.addFocusAnimation()
        
        self.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        self.textColor = .mainText
        self.layer.backgroundColor = UIColor.textFieldBackground.cgColor
        self.layer.cornerRadius = 30
        self.clipsToBounds = true
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        self.leftView = padding
        self.leftViewMode = .always
        self.rightView = padding
        self.rightViewMode = .always
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderColor = UIColor.textFieldBorder.cgColor
        self.layer.borderWidth = 2
        self.layer.masksToBounds = false
    }
    
    func setUsernameStyle() {
        self.applyDefaultStyle()
        self.setPlaceholder(text: "Username", color: .placeholder)
        self.returnKeyType = .next
        self.textContentType = .username
    }
    
    func setPasswordStyle(isRepeat: Bool) {
        self.applyDefaultStyle()
        if isRepeat {
            self.setPlaceholder(text: "Repeat Password", color: .placeholder)
            self.returnKeyType = .done
            self.textContentType = .newPassword
            self.isSecureTextEntry = true
        } else {
            self.setPlaceholder(text: "Password", color: .placeholder)
            self.returnKeyType = .next
            self.textContentType = .password
            self.isSecureTextEntry = true
        }
        
        self.clearsOnBeginEditing = true
        
        
        let button = UIButton()
        button.backgroundColor = nil
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .placeholder
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let action = UIAction { _ in
            self.isSecureTextEntry.toggle()
            let newImage = self.isSecureTextEntry ? UIImage(systemName: "eye") : UIImage(systemName: "eye.slash")
            button.setImage(newImage, for: .normal)
        }
        button.addAction(action, for: .touchUpInside)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 50))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5)
            
        ])
        
        self.rightView = container
        self.rightViewMode = .always
    }
    
    func addFocusAnimation() {
        self.addTarget(self, action: #selector(startFocusAnimation), for: .editingDidBegin)
        self.addTarget(self, action: #selector(stopFocusAnimation), for: .editingDidEnd)
    }
    
    func addLeftImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        imageView.frame = CGRect(x: 10, y: 0, width: 24, height: 24) // Отступ 10
        leftContainer.addSubview(imageView)

        self.leftView = leftContainer
        self.leftViewMode = .always
    }

    @objc private func startFocusAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            self.switchEditingBorder(true)
        }
    }

    @objc private func stopFocusAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
            self.switchEditingBorder(false)
        }
    }
    
    func isAvailableValue(_ value: Bool) {
        self.layer.borderColor = value ? UIColor.rightValueTextField.cgColor : UIColor.wrongValueTextField.cgColor

    }
    
    
    private func switchEditingBorder(_ active: Bool) {
            self.layer.borderColor = active ? UIColor.activeTextField.cgColor : UIColor.textFieldBorder.cgColor

    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: 58)
    }
    
    func setPlaceholder(text: String, color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
}

