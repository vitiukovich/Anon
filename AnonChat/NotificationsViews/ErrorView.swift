//
//  ErrorView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/30/25.
//

import UIKit

class ErrorView: UIView {
    
    static var activeErrorViews = [ErrorView]()

    func show(in view: UIView, duration: TimeInterval = 2.5, message: String, color: UIColor = .wrongValueTextField) {
        self.backgroundColor = .secondBackground
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 9
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
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
        self.translatesAutoresizingMaskIntoConstraints = false
        
        
        let lastErrorView = ErrorView.activeErrorViews.last
        let topAnchorConstraint = lastErrorView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.topAnchor.constraint(equalTo: topAnchorConstraint, constant: 5),
            self.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])
        
        ErrorView.activeErrorViews.append(self)
        
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
            if let index = ErrorView.activeErrorViews.firstIndex(of: self) {
                ErrorView.activeErrorViews.remove(at: index)
            }
        }
    }
}
