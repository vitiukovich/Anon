//
//  ProfileImageView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/17/25.
//

import UIKit

final class ProfileImage: UIView {
    let imageView = UIImageView()
    
    private var color: UIColor?
    private let imageLabel = UILabel()
    
    private var imageViewHeightConstraint: NSLayoutConstraint?
    private var imageViewWidthConstraint: NSLayoutConstraint?
    
    private let height: CGFloat
    
    init(height: CGFloat) {
        self.height = height
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let color = self.color else { return }
        self.layer.borderColor = color.cgColor
    }
    
    
    private func setupUI() {
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: height)
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: height)
        
        self.layer.cornerRadius = height / 2
        self.layer.masksToBounds = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .imageBackground
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .imageBackground
        imageView.tintColor = .activeButton
        imageView.layer.cornerRadius = height / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(imageView)

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height),
            self.widthAnchor.constraint(equalToConstant: height),
            
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func setupLabel() {
        imageLabel.setDefault(ofSize: 28, weight: .medium, color: .mainText)
        imageLabel.textAlignment = .center
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageLabel)
        
        NSLayoutConstraint.activate([
            imageViewHeightConstraint!,
            imageViewWidthConstraint!,
            
            imageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func setImageWithLabel(imageName: String, text: String) {
        if imageName != "" {
            imageView.image = UIImage(named: imageName)
            imageLabel.isHidden = true
        } else {
            imageView.image = nil
            imageLabel.text = text
            imageLabel.isHidden = false
        }
    }
    
    func setImage(imageName: String) {
        var frame = self.height
        
        if let oldHeightConstraint = imageViewHeightConstraint {
            imageView.removeConstraint(oldHeightConstraint)
        }
        if let oldWidthConstraint = imageViewWidthConstraint {
            imageView.removeConstraint(oldWidthConstraint)
        }
        
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: frame)
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: frame)

        if imageName != "" {
            imageView.image = UIImage(named: imageName)
            imageView.layer.cornerRadius = height / 2
            
        } else {
            imageView.image = UIImage(systemName: "person.fill")
            imageView.layer.cornerRadius = 0
            frame = self.height / 2
        }
        
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: frame)
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: frame)
        
        NSLayoutConstraint.activate([
            imageViewHeightConstraint!,
            imageViewWidthConstraint!
        ])

        
        
    }
    
    func setShadow(opacity: Float, radius: CGFloat) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = radius
    }
    
    func setBorder(color: UIColor, borderWidth: CGFloat) {
        self.color = color
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
    }
}
