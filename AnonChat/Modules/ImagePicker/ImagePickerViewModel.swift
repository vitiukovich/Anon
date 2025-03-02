//
//  ImagePickerViewModel.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/8/25.
//

import UIKit
import Combine

final class ImagePickerViewModel {
    @Published var isSendButtonEnabled: Bool = false
    @Published var selectedImage: UIImage? = nil

    private let chat: Chat!
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    deinit {

    }
    
    
    func sendImage(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUID = UserManager.shared.currentUID else {
            completion(.failure(NSError(domain: "UserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current UID not found"])))
            return
        }
        guard let selectedImage = selectedImage else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image not selected"])))
            return
        }
        
        let message = Message(senderID: currentUID, recipientID: chat.contactID, image: selectedImage)
        MessageManager.shared.sendMessage(to: chat, message: message, completion: completion)
    }
    
    func updateImage(_ image: UIImage) {
        selectedImage = image
        isSendButtonEnabled = true
    }
}
