//
//  CustomButton.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/19/25.
//

import UIKit

class CustomButton: UIButton {
    
    func setDefaultButton(withTitle text: String, height: CGFloat = 52, color: UIColor? = nil) {
        self.addTapedAnimation()
        if let color = color {
            self.backgroundColor = color
        } else {
            self.backgroundColor = .activeButton
        }
        self.titleLabel?.textColor = .white
        self.setTitle(text, for: .normal)
        self.layer.cornerRadius = height / 2
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height)
            ])
    }
    
    func setCheckBoxButton() {
        var isSelected = false
        self.backgroundColor = nil
        self.addTapedAnimation()
        self.tintColor = .activeButton
        let image = UIImage(systemName: "rectangle")?.withConfiguration(UIImage.SymbolConfiguration(paletteColors: [.activeButton, .mainText]))
        self.setImage(image, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let action = UIAction { _ in
            if !isSelected {
                let image = UIImage(systemName: "checkmark.rectangle")?.withConfiguration(UIImage.SymbolConfiguration(paletteColors: [.mainText, .activeButton]))
                self.setImage(image, for: .normal)
                isSelected = true
            } else if isSelected {
                let image = UIImage(systemName: "rectangle")?.withConfiguration(UIImage.SymbolConfiguration(paletteColors: [.activeButton, .mainText]))
                self.setImage(image, for: .normal)
                isSelected = false
            }
        }
        self.addAction(action, for: .touchUpInside)
    }
    
    func setCircleButton(height: CGFloat, imageName: String) {
        self.addTapedAnimation()
        self.addShadow()
        self.layer.cornerRadius = height / 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.backgroundColor = .secondBackground
        self.setTitleColor(.mainText, for: .normal)
        self.setImage(UIImage(systemName: imageName), for: .normal)
        self.tintColor = .mainText
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height),
            self.widthAnchor.constraint(equalToConstant: height),
        ])
    }
    
    func setProfileButton(forUser user: ContactDTO, height: CGFloat = 50) {
        self.addTapedAnimation()
        self.addShadow()
        self.layer.cornerRadius = height / 2
        self.layer.borderColor = UIColor.imageBorder.cgColor
        self.layer.borderWidth = 2
        self.imageView?.layer.cornerRadius = height / 2
        self.backgroundColor = .secondBackground
        self.setTitleColor(.mainText, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if user.profileImage != "" {
            self.setImage(UIImage(named: user.profileImage), for: .normal)
        } else {
            self.setTitle(user.username.first?.uppercased(), for: .normal)
        }
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height),
            self.widthAnchor.constraint(equalToConstant: height),
        ])
    }
    
    func addTapedAnimation() {
        self.addTarget(self, action: #selector(touchDownAnimation), for: .touchDown)
        self.addTarget(self, action: #selector(touchUpAnimation), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchUpAnimation), for: .touchDragExit)
    }
    
    private func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 9
        self.layer.masksToBounds = false
    }
    

    
    @objc private func touchDownAnimation(){
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        
    }
    
    @objc private func touchUpAnimation(){
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
    
    
}
