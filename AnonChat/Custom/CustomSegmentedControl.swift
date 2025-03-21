//
//  SegmentedControl.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/15/25.
//

import UIKit

class CustomSegmentedControl: UIView {
    
    private var subViewLeadingConstraint: NSLayoutConstraint!
    private var subViewTrailingConstraint: NSLayoutConstraint!
    
    private let subView = UIView()
    private let firstButton = UIButton()
    private let secondButton = UIButton()
    private let width: CGFloat
    
    init(width: CGFloat) {
        self.width = width
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .mainBackground
        self.layer.cornerRadius = 26
        self.layer.masksToBounds = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        subView.backgroundColor = .secondBackground
        subView.layer.cornerRadius = 22
        subView.layer.shadowColor = UIColor.black.cgColor
        subView.layer.shadowOpacity = 0.05
        subView.layer.shadowOffset = CGSize(width: 0, height: 0)
        subView.layer.shadowRadius = 4
        subView.layer.masksToBounds = false
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        setActive(activeButton: firstButton, inactiveButton: secondButton)
        firstButton.backgroundColor = nil
        firstButton.translatesAutoresizingMaskIntoConstraints = false
        secondButton.backgroundColor = nil
        secondButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(subView)
        self.addSubview(firstButton)
        self.addSubview(secondButton)
        
        subViewLeadingConstraint = subView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4)
        subViewTrailingConstraint = subView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -width / 2)
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: width),
            self.heightAnchor.constraint(equalToConstant: 52),
            
            subView.widthAnchor.constraint(equalToConstant: width / 2 - 4),
            subView.heightAnchor.constraint(equalToConstant: 44),
            subViewLeadingConstraint,
            subViewTrailingConstraint,
            subView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            
            firstButton.widthAnchor.constraint(equalToConstant: width / 2),
            firstButton.heightAnchor.constraint(equalToConstant: 50),
            firstButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            firstButton.topAnchor.constraint(equalTo: self.topAnchor),
            
            secondButton.widthAnchor.constraint(equalToConstant: width / 2),
            secondButton.heightAnchor.constraint(equalToConstant: 50),
            secondButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            secondButton.topAnchor.constraint(equalTo: self.topAnchor)
            
        ])
    }
    
    func setTitles(firstTitle: String, secondTitle: String) {
        firstButton.setTitle(firstTitle, for: .normal)
        secondButton.setTitle(secondTitle, for: .normal)
    }
    
    func setActions(firstClosure: @escaping () -> (), secondClosure: @escaping () -> ()) {
        
        firstButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            firstClosure()
            UIView.animate(withDuration: 0.3) {
                self.setActive(activeButton: self.firstButton, inactiveButton: self.secondButton)
                self.subViewLeadingConstraint.constant = 4
                self.subViewTrailingConstraint.constant = -self.width / 2
                self.layoutIfNeeded()
            }
        }, for: .touchUpInside)
        
        secondButton.addAction(UIAction { [weak self]  _ in
            guard let self else { return }
            secondClosure()
            UIView.animate(withDuration: 0.3) {
                self.setActive(activeButton: self.secondButton, inactiveButton: self.firstButton)
                self.subViewLeadingConstraint.constant = self.width / 2
                self.subViewTrailingConstraint.constant = -4
                self.layoutIfNeeded()
            }
        }, for: .touchUpInside)
    }
    
    func setColors(background color1: UIColor, active color2: UIColor) {
        self.backgroundColor = color1
        self.subView.backgroundColor = color2
    }
    
    private func setActive(activeButton: UIButton, inactiveButton: UIButton) {
            activeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            activeButton.setTitleColor(.mainText, for: .normal)
            inactiveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            inactiveButton.setTitleColor(.placeholder, for: .normal)
    }
}
