//
//  MessageNotificationView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/4/25.
//

import UIKit

class MessageNotificationView: UIView {
    
    

    private let senderImage = ProfileImage(height: 50)
    private let messageLabel = UILabel()
    private let senderLabel = UILabel()
    private let action: () -> ()
    
    init(sender: String, message: String, image: String, action: @escaping () -> ()) {
        self.action = action
        super.init(frame: CGRect(x: 10, y: -100, width: UIScreen.main.bounds.width - 20, height: 80))
        self.setupUI(sender: sender, message: message, image: image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(sender: String, message: String, image: String) {
        self.backgroundColor = .secondBackground
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        
        senderLabel.setDefault(text: sender, ofSize: 16, weight: .semibold, color: .mainText)
        senderLabel.textAlignment = .left
        
        messageLabel.setDefault(text: message, ofSize: 14, weight: .medium, color: .mainText)
        messageLabel.numberOfLines = 1
        messageLabel.textAlignment = .left
        
        senderImage.setImage(imageName: image)
        senderImage.setShadow(opacity: 0.1, radius: 5)
        
        let stackView = UIStackView(arrangedSubviews: [senderLabel, messageLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        addSubview(senderImage)
        
        NSLayoutConstraint.activate([
            senderImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            senderImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: self.senderImage.trailingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        self.addGestureRecognizer(swipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    func show() {
        guard let window = getMainWindow() else { return }
                window.addSubview(self)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = 50
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.dismiss()
            }
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = -100
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    private func getMainWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        dismiss()
        action()
    }
    
    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        if translation.y < 0 {
            self.frame.origin.y += translation.y
            gesture.setTranslation(.zero, in: self)
        }

        if gesture.state == .ended {
            if self.frame.origin.y < 10 {
                dismiss()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.frame.origin.y = 50
                }
            }
        }
    }
}
