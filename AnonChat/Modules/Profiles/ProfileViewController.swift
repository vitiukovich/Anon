//
//  ProfileViewController.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/11/25.
//

import UIKit
import Combine

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let viewModel: ProfileViewModel
    private let coordinator: ProfileCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    private var images: [UIImage] = []
    
    private let contact: ContactDTO
    
    private let backgroundImage = UIImageView()
    private let profileLabel = UILabel()
    private let backButton = CustomButton()
    private let addContactButton = CustomButton()
    private let profileImage = ProfileImage(height: 134)
    private let usernameLabel = UILabel()
    private let statusView = UIView()
    
    private let chatButton = CustomButton()
    private let autoDeleteButton = CustomButton()
    private let muteButton = CustomButton()
    private let blockButton = CustomButton()
    private let chatLabel = UILabel()
    private let autoDeleteLabel = UILabel()
    private let muteLabel = UILabel()
    private let blockLabel = UILabel()
    private let buttonStackView = UIStackView()
    
    private let imageView = ImageOverView()
    
    private let subview = UIView()
    private let segmentController = CustomSegmentedControl(width: 325)
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 100)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(contact: ContactDTO, viewModel: ProfileViewModel, coordinator: ProfileCoordinator) {
        self.contact = contact
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .mainBackground
        
        backgroundImage.setBackgroundImage(toView: self.view)
        profileLabel.setDefault(text: "Profile", ofSize: 16, weight: .semibold, color: .mainText)
        backButton.setCircleButton(height: 40, imageName: "arrow.left")
        addContactButton.setCircleButton(height: 40, imageName: "plus")
        profileImage.setShadow(opacity: 0.1, radius: 9)
        profileImage.setBorder(color: .imageBorder, borderWidth: 7)
        profileImage.setImage(imageName: contact.profileImage)
        usernameLabel.setDefault(text: contact.username, ofSize: 24, weight: .semibold, color: .mainText)
        
        configureStatusView()
        configureButtons()
        blockButton.tintColor = .wrongValueTextField

        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        subview.setSubview(toView: self.view)
        segmentController.setTitles(firstTitle: "Image", secondTitle: "Documents")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        
        view.addSubview(profileLabel)
        view.addSubview(backButton)
        view.addSubview(addContactButton)
        view.addSubview(profileImage)
        view.addSubview(usernameLabel)
        view.addSubview(statusView)
        view.addSubview(buttonStackView)
        
        subview.addSubview(segmentController)
        subview.addSubview(collectionView)

        NSLayoutConstraint.activate([
            profileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            addContactButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            addContactButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 30),
            
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 30),
            
            statusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 20),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            buttonStackView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 25),
            
            subview.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 25),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            segmentController.centerXAnchor.constraint(equalTo: subview.centerXAnchor),
            segmentController.topAnchor.constraint(equalTo: subview.topAnchor, constant: 35),
            
            collectionView.topAnchor.constraint(equalTo: segmentController.bottomAnchor, constant: 15),
            collectionView.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            collectionView.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            collectionView.bottomAnchor.constraint(equalTo: subview.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    
    private func bindViewModel() {
        viewModel.$images
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                guard let self else { return }
                self.images = images
                collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isContactAdded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAdded in
                guard let self else { return }
                let buttonImage = isAdded ? "trash" : "plus"
                let tintColor = isAdded ? UIColor.wrongValueTextField : UIColor.mainText
                self.addContactButton.setImage(UIImage(systemName: buttonImage), for: .normal)
                self.addContactButton.tintColor = tintColor
            }
            .store(in: &cancellables)
        viewModel.$isContactBlocked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBlocked in
                guard let self else { return }
                let buttonImage = isBlocked ? "person" : "person.slash"
                self.blockButton.tintColor = isBlocked ? UIColor.mainText : UIColor.wrongValueTextField
                self.blockLabel.text = isBlocked ? "Unblock" : "Block"
                self.blockButton.setImage(UIImage(systemName: buttonImage), for: .normal)
            }
            .store(in: &cancellables)
        
        chatButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.coordinator.showChat(withContact: contact)
        }, for: .touchUpInside)
        
        muteButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showReport(vc: self, contact: self.contact)
        }, for: .touchUpInside)
        
        blockButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if viewModel.isContactBlocked {
                self.viewModel.toggleBlockPressed()
            } else {
                coordinator.showBlockView(from: self, contact: contact, action: UIAction { [weak self] _ in
                    guard let self else { return }
                    self.viewModel.toggleBlockPressed()
                })
            }
        }, for: .touchUpInside)
        
        autoDeleteButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            coordinator.showAutoDelete(vc: self, option: viewModel.autoDeleteOption, contactID: viewModel.contactID)
        }, for: .touchUpInside)
        
        backButton.addAction(UIAction {[weak self] _ in
            guard let self = self else { return }
            self.coordinator.back()
        }, for: .touchUpInside)
        
        addContactButton.addAction(UIAction {[weak self] _ in
            guard let self = self else { return }
            self.viewModel.toggleContactPressed()
        }, for: .touchUpInside)
    }

    
    private func configureButtons() {
        let buttons = [chatButton, autoDeleteButton, muteButton, blockButton]
        let labels = [chatLabel, autoDeleteLabel, muteLabel, blockLabel]
        let buttonImages = ["message", "clock", "exclamationmark.shield", "person.slash"]
        let labelTitles = ["Chat", "Timer", "Report", "Block"]
        
        for (index, button) in buttons.enumerated() {
            let stackView = UIStackView()
            button.setCircleButton(height: 50, imageName: buttonImages[index])
            labels[index].setDefault(text: labelTitles[index], ofSize: 12, weight: .semibold, color: .mainText)
            labels[index].numberOfLines = 1
            
            stackView.addArrangedSubview(button)
            stackView.addArrangedSubview(labels[index])
            stackView.axis = .vertical
            stackView.spacing = 10
            
            buttonStackView.addArrangedSubview(stackView)
        }

    }
    
    private func configureStatusView() {
        let label = UILabel()
        label.setDefault(text: contact.status, ofSize: 13, weight: .medium, color: .activeButton)
            
        statusView.backgroundColor = .imageBackground
        statusView.layer.cornerRadius = 16
        statusView.translatesAutoresizingMaskIntoConstraints = false
            
        statusView.addSubview(label)
            
        NSLayoutConstraint.activate([
            statusView.heightAnchor.constraint(equalToConstant: 32),
            label.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -12),
        ])
    }
    
    //MARK: Collection View Delegate & Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = images[indexPath.row]

        cell.contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageView.setup(toView: self)
        imageView.show(withDuration: 0.3, image: images[indexPath.row])
    }
}
