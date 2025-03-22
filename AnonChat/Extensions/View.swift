//
//  View.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/14/25.
//

import UIKit

extension UIView {
    
    func recursiveSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        for subview in subviews {
            if let match = subview as? T {
                result.append(match)
            }
            result.append(contentsOf: subview.recursiveSubviews(of: type))
        }
        return result
    }
    
    func setSubview(toView view: UIView) {
        self.backgroundColor = .secondBackground
        self.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        self.setCornersMask(toView: self, parentView: view)
    }
    
    func setCornersMask(toView view: UIView, parentView: UIView) {
        let path = UIBezierPath(
            roundedRect: parentView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 25, height: 25))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }
}

