//
//  MessageView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import UIKit

final class MessageView: UIView {
    
    var onImageTap: ((UIImage) -> Void)?
    
    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let isCurrentUser: Bool
    
    private let image: UIImage?
    
    init(isCurrentUser: Bool!, massage: String, time: Date, image: UIImage? = nil) {
        self.isCurrentUser = isCurrentUser
        self.image = image
        super.init(frame: .zero)
        setupUI()
        messageLabel.text = massage
        timeLabel.text = timeAgoString(from: time)
        setCornersMask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCornersMask()
    }
    
    private func setupUI() {
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        
        timeLabel.numberOfLines = 1
        
        self.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.setDefault(ofSize: 12, weight: .medium, color: .placeholder)
        
        if isCurrentUser {
            self.backgroundColor = .activeButton
            messageLabel.setDefault(ofSize: 16, weight: .medium, color: .white)
            
        } else {
            self.backgroundColor = .mainBackground
            messageLabel.setDefault(ofSize: 16, weight: .medium, color: .mainText)
        }
        messageLabel.textAlignment = .left
        
        self.addSubview(messageLabel)
        self.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        if let image = image {
            imageView.image = image
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            let aspectRatio = image.size.height / image.size.width
            
            self.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 200),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: aspectRatio),
                imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
                imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
                imageView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -10)
                
            ])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func imageTapped() {
        guard let image = image else { return }
        onImageTap?(image)
    }
    
    private func setCornersMask() {
        let roundingCorners: UIRectCorner = isCurrentUser ? [.topLeft, .bottomLeft, .topRight,] : [.topRight, .bottomRight, .topLeft]
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: roundingCorners,
            cornerRadii: CGSize(width: 20, height: 20)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    private func timeAgoString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year],
            from: date,
            to: now
        )
        
        if let years = components.year, years > 0 {
            return "\(years) year\(years > 1 ? "s" : "") ago"
        } else if let months = components.month, months > 0 {
            return "\(months) month\(months > 1 ? "s" : "") ago"
        } else if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks) week\(weeks > 1 ? "s" : "") ago"
        } else if let days = components.day, days > 0 {
            return "\(days) day\(days > 1 ? "s" : "") ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
        } else {
            return "just now"
        }
    }
}
