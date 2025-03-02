//
//  Label.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/14/25.
//

import UIKit

extension UILabel {
    
    func setDefault(text: String? = nil, ofSize: CGFloat, weight: UIFont.Weight, color: UIColor) {
        self.textColor = color
        self.font = UIFont.systemFont(ofSize: ofSize, weight: weight)
        self.numberOfLines = 0
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        if let text = text {
            self.text = text
        }
    }
}
