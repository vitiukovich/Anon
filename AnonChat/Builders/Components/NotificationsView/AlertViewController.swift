//
//  AlertViewController.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/16/25.
//

import UIKit

class AlertViewController: UIViewController {

    private let backgroundView = UIView()
    private let subview = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let cancelButton = CustomButton()
    private var imageView: UIImageView?
    
    private let alertTitle: String
    private let alertMessage: String
    
    init(title: String, message: String, imageName: String? = nil) {
        self.alertTitle = title
        self.alertMessage = message
        super.init(nibName: nil, bundle: nil)
        if let imageName = imageName {
            addImage(named: imageName)
        }
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.subview.transform = .identity
            self.cancelButton.transform = .identity
        }
    }
    
    func setupUI() {
        backgroundView.backgroundColor = .darkenedView
        backgroundView.frame = view.bounds
        backgroundView.alpha = 0
        
        titleLabel.setDefault(text: alertTitle, ofSize: 28, weight: .semibold, color: .mainText)
        messageLabel.setDefault(text: alertMessage, ofSize: 18, weight: .regular, color: .secondText)
        messageLabel.numberOfLines = 0
        
        cancelButton.setCircleButton(height: 50, imageName: "xmark")
        cancelButton.addAction(UIAction { [weak self]_ in
            guard let self = self else { return }
            self.dismiss()
        }, for: .touchUpInside)
        cancelButton.transform = CGAffineTransform(translationX: 0, y: 300)
        
        subview.setSubview(toView: view)
        subview.backgroundColor = .secondBackground
        subview.transform = CGAffineTransform(translationX: 0, y: 300)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundView)
        view.addSubview(subview)
        view.addSubview(cancelButton)
        subview.addSubview(titleLabel)
        subview.addSubview(messageLabel)
        subview.addSubview(stackView)
        
        if let imageView = imageView {
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: subview.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: subview.topAnchor, constant: 25),
                imageView.heightAnchor.constraint(equalToConstant: 125),
                imageView.widthAnchor.constraint(equalToConstant: 125),
                
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: subview.topAnchor, constant: 25),
            ])
        }
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            cancelButton.bottomAnchor.constraint(equalTo: subview.topAnchor, constant: -25),
            
            
            titleLabel.centerXAnchor.constraint(equalTo: subview.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            messageLabel.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            
            stackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 25),
            stackView.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    func addButton(withTitle: String, color: UIColor? = UIColor.activeButton, action: UIAction? = nil) {
        let button = CustomButton()
        button.setDefaultButton(withTitle: withTitle, height: 50)
        button.backgroundColor = color
        if let action = action {
            button.addAction(action, for: .touchUpInside)
        }
        button.addAction(UIAction { _ in
            self.dismiss()
        }, for: .touchUpInside)
        
        stackView.addArrangedSubview(button)
    }
    
    func addImage(named: String) {
        imageView = UIImageView(image: UIImage(named: named))
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        subview.addSubview(imageView)
    }
    
    func show(fromVC vc: UIViewController) {
        vc.present(self, animated: false)
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.subview.transform = CGAffineTransform(translationX: 0, y: 300)
            self.cancelButton.transform = CGAffineTransform(translationX: 0, y: 300)
            self.backgroundView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    @objc private func handleBackgroundTap() {
        dismiss()
    }
    
    
}
