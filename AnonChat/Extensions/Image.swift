//
//  Image.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/17/25.
//

import UIKit

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let size = CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.rotate(by: radians)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        self.draw(in: CGRect(origin: .zero, size: size))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}
