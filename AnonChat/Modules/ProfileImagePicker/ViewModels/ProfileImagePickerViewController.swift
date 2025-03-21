//
//  ProfileImagePickerViewController.swift
//  chatApp
//
//  Created by Stanislav Vitiuk on 12/24/24.
//

import UIKit

class ProfileImagePickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let viewModel: ProfileImagePickerViewModel
    private let coordinator: ProfileImagePickerCoordinator
    
    private let backgroundImage = UIImageView()
    private let closeButton = CustomButton()
    private let label = UILabel()
    private lazy var collectionView = ProfileImagePickerCollection(view: view)
    
    init(viewModel: ProfileImagePickerViewModel, coordinator: ProfileImagePickerCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainBackground
        setupUI()
        bindActions()
    }
    
    
    private func setupUI(){
        backgroundImage.setBackgroundImage(toView: view)
        closeButton.setCircleButton(height: 40, imageName: "xmark")
        label.setDefault(text: "Choose an avatar", ofSize: 26, weight: .semibold, color: .mainText)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(label)
        view.addSubview(closeButton)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }
    
    private func bindActions() {
        closeButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }, for: .touchUpInside)
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileImageCell", for: indexPath) as! ProfileImagePickerCell
        cell.setupCell(imageName: viewModel.imageData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.updateImage(index: indexPath.row)
        self.dismiss(animated: true)
    }
        
    
}
