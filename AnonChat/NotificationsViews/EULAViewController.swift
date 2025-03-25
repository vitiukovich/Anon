//
//  EULAViewController.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/18/25.
//

import UIKit
import FirebaseAuth

final class EULAViewController: UIViewController {
    private let backgroundImage = UIImageView()
    private let titleLabel = UILabel()
    private let subview = UIView()
    private let textView = UITextView()
    private let agreeButton = CustomButton()
    private let cancelButton = CustomButton()
    
    private let isFirst: Bool
    
    init(isFirst: Bool) {
        self.isFirst = isFirst
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindAction()
    }
    
    func setupUI() {
        view.backgroundColor = .mainBackground
        
        titleLabel.setDefault(text: "End User License Agreement", ofSize: 18, weight: .medium, color: .mainText)
        titleLabel.textAlignment = .left
        backgroundImage.setBackgroundImage(toView: view)
        subview.setSubview(toView: view)
        
        textView.font = UIFont(name: "Manrope-SemiBold", size: 16)
        textView.textColor = .mainText
        textView.backgroundColor = .clear
        textView.attributedText = eulaText()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        subview.addSubview(textView)
        
        if isFirst {
            agreeButton.setDefaultButton(withTitle: "I Agree")
            subview.addSubview(agreeButton)
            
            NSLayoutConstraint.activate([
                agreeButton.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
                agreeButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
                agreeButton.bottomAnchor.constraint(equalTo: subview.safeAreaLayoutGuide.bottomAnchor, constant: -15),
                
                textView.bottomAnchor.constraint(equalTo: agreeButton.topAnchor, constant: -15),
            ])
        } else {
            cancelButton.setCircleButton(height: 50, imageName: "xmark")
            view.addSubview(cancelButton)
            
            NSLayoutConstraint.activate([
                cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
                cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
                
                textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            ])
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45),
            

            

            textView.topAnchor.constraint(equalTo: subview.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -15)
        ])    }
    
    func bindAction() {
        agreeButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            UserDefaults.standard.set(true, forKey: "EULAAccepted")
            self.dismiss(animated: true)
        }, for: .touchUpInside)
        
        cancelButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true)
        }, for: .touchUpInside)
    }
    
    
    func eulaText() -> NSAttributedString {
        let eulaString = """
        1. Acceptance of Terms
        By using the application “AnonChat X”, you agree to this End User License Agreement (EULA) and our Privacy Policy. If you do not agree with any part of these terms, you must stop using the application immediately.

        2. User Responsibility
            •    You are fully responsible for the content you send or share through the app.
            •    AnonChat X is designed for private communication only and does not store or moderate messages.
            •    Any use of the app to share harmful, abusive, illegal, hateful, or threatening content is strictly prohibited.
            •    You agree to comply with all applicable laws and regulations in your jurisdiction.

        3. Reporting and Safety Measures
            •    The app includes a basic reporting tool that allows users to flag inappropriate behavior.
            •    Reported users may be blocked, restricted, or permanently removed from the platform.
            •    All reports are reviewed within 24 hours, and appropriate action is taken.

        4. Account and Access Control
            •    We reserve the right to suspend or terminate user accounts at any time without prior notice for violations of this agreement.
            •    Access to the app may be restricted based on detected misuse or abuse.

        5. Limitation of Liability
            •    The app is provided “as is” without warranties of any kind.
            •    The developer is not responsible for any harm, data loss, or legal consequences arising from the use of the app.
            •    All usage is at your own risk.

        6. Contact Information
        For questions, concerns, or to report inappropriate activity, please contact us:
        Email: vitiukovich@icloud.com)
        
        By continuing to use the app, you confirm that you have read, understood, and agreed to this End User License Agreement.
        """

        let attributedString = NSMutableAttributedString(string: eulaString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Manrope-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.mainText,
            .paragraphStyle: paragraphStyle
        ]

        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Manrope-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.mainText,
            .paragraphStyle: paragraphStyle
        ]

        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
        
        let boldSections = [
            "1. Acceptance of Terms",
            "2. User Responsibility",
            "3. Reporting and Moderation",
            "4. Account and Access Control",
            "5. Limitation of Liability",
            "6. Contact Information",
            "By continuing to use the app, you confirm that you have read, understood, and agreed to this End User License Agreement."
        ]
        
        for section in boldSections {
            if let range = attributedString.string.range(of: section) {
                let nsRange = NSRange(range, in: attributedString.string)
                attributedString.addAttributes(boldAttributes, range: nsRange)
            }
        }
        
        return attributedString
    }
}
