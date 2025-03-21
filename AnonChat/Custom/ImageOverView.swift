//
//  ImageOverView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/9/25.
//

import UIKit

class ImageOverView: UIView{
    let backButton = CustomButton()
    let shareButton = CustomButton()
    
    private let imageView = UIImageView()
    private var image: UIImage?
    private weak var parentView: UIViewController?
    
    func setup(toView parentView: UIViewController) {
        self.parentView = parentView
        
        self.frame = parentView.view.bounds
        self.backgroundColor = .darkenedView
        
        backButton.setCircleButton(height: 40, imageName: "xmark")
        shareButton.setCircleButton(height: 40, imageName: "square.and.arrow.up")

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.alpha = 0
        self.isHidden = true

        
        parentView.view.addSubview(self)
        self.addSubview(imageView)
        self.addSubview(backButton)
        self.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 25),
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            
            shareButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 25),
            shareButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        self.addGestureRecognizer(tapGesture)
        
        backButton.addAction(UIAction {_ in
            self.dismiss(withDuration: 0.3)
        }, for: .touchUpInside)
        
        shareButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            guard let image = self.image else { return }
            
            let activityViewController = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            parentView.present(activityViewController, animated: true)
        }, for: .touchUpInside)
    }
    
    func show(withDuration: CGFloat, image: UIImage) {
        guard let parentView = parentView else { return }
        self.imageView.image = image
        self.isHidden = false
        self.image = image
        UIView.animate(withDuration: withDuration) {
            self.alpha = 1
            parentView.view.layoutIfNeeded()
        }
        
        
    }
    
    func dismiss(withDuration: CGFloat) {
        guard let parentView = self.parentView else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            parentView.view.layoutIfNeeded()
        }) { _ in
            self.isHidden = true
        }
    }

    @objc private func handleBackgroundTap() {
        dismiss(withDuration: 0.3)
    }

}
