//
//  ImagePickerCoordinator.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/8/25.
//

import UIKit
import PhotosUI

protocol ImagePickerCoordinatorDelegate: AnyObject {
    func didSelectImage(_ image: UIImage)
}

final class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate  {
    
    private let navigationController: UINavigationController!
    
    weak var delegate: ImagePickerCoordinatorDelegate?
    weak var viewModel: ImagePickerViewModel?
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
        
    func start(withChat chat: Chat) {
        let strongViewModel = ImagePickerViewModel(chat: chat)
        self.viewModel = strongViewModel
        let viewController = ImagePickerViewController(viewModel: strongViewModel, coordinator: self)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }
    
    func dismiss(vc: UIViewController) {
        vc.dismiss(animated: true)
    }
    
    func showCamera(from viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        viewController.present(cameraPicker, animated: true)
    }
    
    func showPhotoLibrary(from viewController: UIViewController) {
        if #available(iOS 18.0, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            
            viewController.present(picker, animated: true)
        } else {
            let libraryPicker = UIImagePickerController()
            libraryPicker.delegate = self
            libraryPicker.sourceType = .photoLibrary
            libraryPicker.allowsEditing = true
            
            viewController.present(libraryPicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            didSelectImage(selectedImage)
        }
    }
    
    @available(iOS 17.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self else { return }
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.didSelectImage(image)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func didSelectImage(_ image: UIImage) {
        guard let viewModel = self.viewModel else { return }
        viewModel.updateImage(image)
    }
}

