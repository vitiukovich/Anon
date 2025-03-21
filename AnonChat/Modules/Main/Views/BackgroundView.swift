//
//  BackgroundView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/24/25.
//

import UIKit

class BackgroundView: UIView {

    let label = UILabel()
    
    func configure(frame: CGRect) {
        self.frame = frame
        label.setDefault(ofSize: 28, weight: .medium, color: .mainText)
        
        let imageView = UIImageView(image: .noContact)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 45),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 132),
            imageView.widthAnchor.constraint(equalToConstant: 132),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 35),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -35)
        ])
    }

}
