//
//  ErrorView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/30/25.
//

import UIKit

class ErrorView: UIView {

    private let label = UILabel()
    
    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(message: String) {
        self.backgroundColor = .secondBackground
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
        self.alpha = 0
        
        label.setDefault(text: message, ofSize: 16, weight: .medium, color: .wrongValueTextField)

        self.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ])
    }

    func show(in view: UIView, duration: TimeInterval = 2.5, message: String) {
        setupUI(message: message)
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.hide()
            }
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
