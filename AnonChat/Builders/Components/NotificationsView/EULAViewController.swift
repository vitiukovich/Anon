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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindAction()
    }
    
    func setupUI() {
        view.backgroundColor = .mainBackground
        
        titleLabel.setDefault(text: "Terms of Use & Privacy Policy", ofSize: 20, weight: .medium, color: .mainText)
        backgroundImage.setBackgroundImage(toView: view)
        subview.setSubview(toView: view)
        
        textView.font = UIFont(name: "Manrope-SemiBold", size: 16)
        textView.textColor = .mainText
        textView.backgroundColor = .clear
        textView.attributedText = eulaText()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        agreeButton.setDefaultButton(withTitle: "I Agree")
        
        view.addSubview(titleLabel)
        subview.addSubview(textView)
        subview.addSubview(agreeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45),
            
            agreeButton.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            agreeButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            agreeButton.bottomAnchor.constraint(equalTo: subview.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            
            textView.bottomAnchor.constraint(equalTo: agreeButton.topAnchor, constant: -15),
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
    }
    
    
    func eulaText() -> NSAttributedString {
        let eulaString = """
        1. Acceptance of Terms
        By using this application ("AnonChat X"), you agree to abide by this End User License Agreement ("EULA") and our Privacy Policy. If you do not agree with these terms, you must stop using the App immediately.  

        2. User Responsibility 
        • Users are fully responsible for the content they send.  
        • The app is designed for private conversations only and does not moderate messages.  
        • Threats, insults, hate speech, and illegal content are strictly prohibited.  
        • Users must comply with the laws of their country while using the App.  

        3. Reporting and Moderation 
        • The App provides a reporting system that allows users to flag inappropriate behavior.  
        • If complaints are received, the sender may be blocked and/or restricted from using the App.  
        • Complaints are reviewed within 24 hours, and appropriate actions are taken.  

        4. Account Actions and Termination 
        • The developer reserves the right to remove users who violate the terms without prior notice.  
        • The App may restrict, suspend, or terminate accounts at any time if a violation is detected.  

        5. Limitation of Liability 
        • The App is provided "as is", without warranties of any kind.  
        • The developer is not responsible for any damages, losses, or consequences arising from the use of the App.  
        • Users acknowledge that all interactions are at their own risk.  

        6. Contact Information  
        For any issues, questions, or to report inappropriate activity, users can contact support at:  
        Email: vitiukovich@icloud.com  

        Final Notes  
        By continuing to use the App, you confirm that you have read, understood, and agreed to this EULA.  
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
            "4. Account Actions and Termination",
            "5. Limitation of Liability",
            "6. Contact Information",
            "Final Notes"
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
