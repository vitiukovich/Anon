//
//  ImageView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/14/25.
//

import UIKit

extension UIImageView {
    
    func setBackgroundImage(toView view: UIView) {
        self.image = .background
        self.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 5),
            self.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.242)
        ])
    }
}
