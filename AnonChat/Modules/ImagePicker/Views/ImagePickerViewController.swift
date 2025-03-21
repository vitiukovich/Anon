//
//  ImagePickerViewController.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/8/25.
//

import UIKit
import PhotosUI
import Combine

class ImagePickerViewController: UIViewController {
    
    private let backgroundImage = UIImageView()
    private let imageView = UIImageView()
    
    private let cameraButton = CustomButton()
    private let libraryButton = CustomButton()
    private let cancelButton = CustomButton()
    private let sendButton = CustomButton()
    
    private let titleLabel = UILabel()
    private let subview = UIView()
    
    private weak var viewModel: ImagePickerViewModel?
    private weak var coordinator: ImagePickerCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ImagePickerViewModel, coordinator: ImagePickerCoordinator) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private func setupUI() {
        view.backgroundColor = .mainBackground
        
        backgroundImage.setBackgroundImage(toView: view)
        cancelButton.setCircleButton(height: 40, imageName: "arrow.left")
        sendButton.setCircleButton(height: 50, imageName: "paperplane.fill")
        sendButton.backgroundColor = .inactiveButton
        sendButton.isEnabled = false
        sendButton.tintColor = .white
        subview.setSubview(toView: view)
        
        titleLabel.setDefault(text: "Send image", ofSize: 28, weight: .semibold, color: .mainText)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        libraryButton.setDefaultButton(withTitle: "Library", height: 52)
        
        cameraButton.setDefaultButton(withTitle: "Camera", height: 52)
        
        view.addSubview(imageView)
        view.addSubview(cancelButton)
        view.addSubview(sendButton)
        view.addSubview(subview)
        
        
        subview.addSubview(cameraButton)
        subview.addSubview(libraryButton)
        
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            
            sendButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.topAnchor.constraint(equalTo: libraryButton.topAnchor, constant: -15),
            
            libraryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            libraryButton.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            libraryButton.trailingAnchor.constraint(equalTo: subview.centerXAnchor, constant: -5),
            
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            cameraButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            cameraButton.leadingAnchor.constraint(equalTo: subview.centerXAnchor, constant: 5),
            
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        guard let coordinator = coordinator else { return }
        viewModel.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                imageView.image = image
                self.view.layoutIfNeeded()
            }
            .store(in: &cancellables)
        
        viewModel.$isSendButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                sendButton.isEnabled = value
                sendButton.backgroundColor = value ? .activeButton : .inactiveButton
            }
            .store(in: &cancellables)
        
        cancelButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.dismiss(vc: self)
        }, for: .touchUpInside)
        
        sendButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            showLoadingOnButton(true)
            viewModel.sendImage { [weak self] result in
                guard let self else { return }
                switch result {
                case .success():
                    coordinator.dismiss(vc: self)
                    self.showLoadingOnButton(false)
                case .failure(let error):
                    ErrorView().show(in: self.view, message: error.localizedDescription)
                    self.showLoadingOnButton(false)
                    
                }
            }
        }, for: .touchUpInside)
        
        libraryButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showPhotoLibrary(from: self)
        }, for: .touchUpInside)
        
        cameraButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showCamera(from: self)
        }, for: .touchUpInside)
    }
    
    func showLoadingOnButton(_ show: Bool) {
        if show {
            sendButton.isEnabled = false
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.tag = 99999
            indicator.color = .mainText
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            sendButton.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
            ])
            
            indicator.startAnimating()
            sendButton.setImage(nil, for: .normal)
            sendButton.backgroundColor = .inactiveButton
        } else {
            sendButton.isEnabled = true
            if let indicator = sendButton.viewWithTag(99999) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
            sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
            sendButton.backgroundColor = .activeButton
        }
    }
}
