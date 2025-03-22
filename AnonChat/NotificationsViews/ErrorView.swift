//
//  ErrorView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/30/25.
//

import UIKit

class ErrorView: UIView {

    static func removeExisting(from root: UIView) {
        root.recursiveSubviews(of: ErrorView.self).forEach { existing in
            UIView.animate(withDuration: 0.2, animations: {
                existing.alpha = 0
            }, completion: { _ in
                existing.removeFromSuperview()
            })
        }
    }
    
    func show(in view: UIView, duration: TimeInterval = 2.5, message: String, color: UIColor = .wrongValueTextField) {
        ErrorView.removeExisting(from: view)
        
        self.backgroundColor = .secondBackground
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 9
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.alpha = 0
        
        let label = UILabel()
        label.setDefault(text: message, ofSize: 16, weight: .medium, color: color)

        self.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        ])
        
        view.addSubview(self)
        

        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
        
        UIView.animate(withDuration: 0.6, animations: {
            self.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.hide()
            }
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.6, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
