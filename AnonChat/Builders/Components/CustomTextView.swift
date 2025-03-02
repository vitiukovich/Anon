//
//  CustomTextView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/23/25.
//

import UIKit

class CustomTextView : UITextView, UITextViewDelegate {
    
    var didChangeHeight: ((CGFloat) -> Void)?
    
    let leftButton = CustomButton()
    let rightButton = CustomButton()
    let placeholder = UILabel()
    var isRightButtonActive = true
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    private let maxHeight: CGFloat = 230
    
    init() {
        super.init(frame: .zero, textContainer: .none)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor.textFieldBorder.cgColor
    }
    
    private func setupUI() {
        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .textFieldBackground
        self.layer.cornerRadius = 30
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderColor = UIColor.textFieldBorder.cgColor
        self.layer.borderWidth = 2
        self.layer.masksToBounds = false
        self.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 50)
        
        self.isScrollEnabled = false
        self.font = .systemFont(ofSize: 18, weight: .regular)
        self.textColor = .mainText
      
        textViewHeightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: 58)
        textViewHeightConstraint.isActive = true

        placeholder.setDefault(text: "Type message...", ofSize: 18, weight: .regular, color: .placeholder)
        
        leftButton.backgroundColor = .clear
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        leftButton.tintColor = .activeButton
        leftButton.addTapedAnimation()
        
        rightButton.backgroundColor = .clear
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        rightButton.isEnabled = false
        rightButton.tintColor = .placeholder
        rightButton.addTapedAnimation()
        
        self.addSubview(leftButton)
        self.addSubview(rightButton)
        self.addSubview(placeholder)
        
        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            placeholder.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            placeholder.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
        ])
    }

    
    //MARK: Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholder.isHidden = true
        leftButton.isHidden = true
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholder.isHidden = false
            leftButton.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = self.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        let newHeight = min(size.height, maxHeight)
        textViewHeightConstraint.constant = newHeight
        
        didChangeHeight?(newHeight)
        
        self.isScrollEnabled = size.height > maxHeight
        
        if self.isScrollEnabled {
            self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            self.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 50)
        } else {
            self.contentInset = .zero
            self.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 50)
        }
        
        if self.text.isEmpty {
            isButtonActive(false)
        } else if isRightButtonActive {
            isButtonActive(true)
        }
    }
    
    func isButtonActive(_ value: Bool) {
        rightButton.isEnabled = value
        rightButton.tintColor = value ? .activeButton : .placeholder
    }
    
    func showLoadingOnButton(_ show: Bool) {
        if show {
            rightButton.isEnabled = false
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.tag = 999999
            indicator.color = .mainText
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            rightButton.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: rightButton.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: rightButton.centerYAnchor)
            ])
            
            indicator.startAnimating()
            rightButton.setImage(nil, for: .normal)
        } else {
            rightButton.isEnabled = true
            if let indicator = rightButton.viewWithTag(999999) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
            rightButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        }
    }
}
