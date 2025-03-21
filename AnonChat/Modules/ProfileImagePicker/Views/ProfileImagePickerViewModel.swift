//
//  ImagePickerViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/21/25.
//

import UIKit

final class ProfileImagePickerViewModel {
    
    
    let imageData: [String] = ["", "prof01", "prof02", "prof03", "prof04", "prof05", "prof06",
                               "prof07", "prof08", "prof09", "prof10", "prof11", "prof12",
                               "prof13", "prof14", "prof15", "prof16", "prof17", "prof18",
                               "prof19", "prof20", "prof21", "prof22", "prof23", "prof24",
                               "prof25", "prof26", "prof27", "prof28"]
    
    private let currentUser = UserManager.shared.currentUser
    
    func updateImage(index: Int) {
        UserManager.shared.updateCurrentUserData(profileImage: imageData[index]) { _ in  }
    }
}
