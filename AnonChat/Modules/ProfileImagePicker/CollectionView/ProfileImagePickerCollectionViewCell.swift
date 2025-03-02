//
//  ProfileImagePickerCell.swift
//  chatApp
//
//  Created by Stanislav Vitiuk on 12/24/24.
//

import UIKit

class ProfileImagePickerCell: UICollectionViewCell {
    
    private let currentImage = UserManager.shared.profileImage
    
    func setupCell(imageName: String) {
        let profileImage = ProfileImage(height: self.frame.height)
        profileImage.setImage(imageName: imageName)
        
        if imageName == currentImage {
            profileImage.setBorder(color: .activeButton, borderWidth: 3)
        } else {
            profileImage.setBorder(color: .activeButton, borderWidth: 0)
        }
        
        contentView.addSubview(profileImage)
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            profileImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            profileImage.topAnchor.constraint(equalTo: self.topAnchor),
            profileImage.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
