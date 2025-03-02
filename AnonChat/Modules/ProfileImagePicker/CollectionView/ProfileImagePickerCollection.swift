//
//  ProfileImagePicker.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/21/25.
//

import UIKit

class ProfileImagePickerCollection: UICollectionView {

    init (view: UIView) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 4, height: view.frame.width / 4)
        layout.minimumLineSpacing = 25
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.backgroundColor = .mainBackground
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
        self.isScrollEnabled = true
        self.register(ProfileImagePickerCell.self, forCellWithReuseIdentifier: "ProfileImageCell")
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    


    


}
