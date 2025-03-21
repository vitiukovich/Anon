//
//  Label.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/14/25.
//

import UIKit

extension UILabel {
    
    enum ManropeWeight: String {
        case regular = "Manrope-Regular"
        case extralight = "Manrope-ExtraLight"
        case light = "Manrope-Light"
        case medium = "Manrope-Medium"
        case semibold = "Manrope-SemiBold"
        case bold = "Manrope-Bold"
        case heavy = "Manrope-ExtraBold"
    }
    
    func setDefault(text: String? = nil, ofSize: CGFloat, weight: ManropeWeight, color: UIColor) {
        self.textColor = color
        self.font = UIFont(name: weight.rawValue, size: ofSize)
        self.numberOfLines = 0
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        if let text = text {
            self.text = text
        }
    }
}
