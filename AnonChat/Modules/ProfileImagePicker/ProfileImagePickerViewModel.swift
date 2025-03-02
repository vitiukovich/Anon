//
//  ImagePickerViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/21/25.
//

import UIKit

final class ProfileImagePickerViewModel {
    
    
    let imageData: [String] = ["", "profile01.svg", "profile02.svg", "profile03.svg", "profile04.svg",
                               "profile05.svg", "profile06.svg", "profile07.svg", "profile08.svg",
                               "profile09.svg", "profile01.svg", "profile02.svg", "profile03.svg",
                               "profile04.svg", "profile05.svg", "profile06.svg", "profile07.svg",
                               "profile08.svg", "profile09.svg", "profile08.svg", "profile09.svg",
                               "profile01.svg", "profile02.svg", "profile03.svg", "profile04.svg",
                                "profile05.svg", "profile06.svg", "profile07.svg", "profile08.svg",
                                "profile09.svg", "profile01.svg", "profile02.svg", "profile03.svg",
                                "profile04.svg", "profile05.svg", "profile06.svg", "profile07.svg",]
    
    private let currentUser = UserManager.shared.currentUser
    
    func updateImage(index: Int) {
        UserManager.shared.updateCurrentUserData(profileImage: imageData[index]) { result in
            switch result {
            case .failure(let error): break
            case .success(): break
            }
        }
    }
}
