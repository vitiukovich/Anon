//
//  AutoDeleteView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/9/25.
//

import UIKit

class AutoDeleteView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum Option: String {
        case off = "Off"
        case oneHour = "1 Hour"
        case oneDay = "1 Day"
        case oneWeek = "1 Week"
        
        var index: Int {
            switch self {
            case .off:
                return 0
            case .oneHour:
                return 1
            case .oneDay:
                return 2
            case .oneWeek:
                return 3
            }
        }
        
        var timeInterval: TimeInterval? {
            switch self {
            case .off:
                return nil
            case .oneHour:
                return 3600
            case .oneDay:
                return 86400
            case .oneWeek:
                return 604800
            }
        }
    }
    
    private var selectedOption: Option
    
    private let backgroundView = UIView()
    private let subview = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let cancelButton = CustomButton()
    private let doneButton = CustomButton()
    private let pickerView = UIPickerView()
    
    
    init(selectedOption: Option) {
        self.selectedOption = selectedOption
        super.init(nibName: nil, bundle: nil)
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
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(selectedOption.index, inComponent: 0, animated: false)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.backgroundColor = .darkenedView
        backgroundView.frame = view.bounds
        backgroundView.alpha = 0
        
        titleLabel.setDefault(text: "Auto-delete", ofSize: 28, weight: .semibold, color: .mainText)
        messageLabel.setDefault(text: "Select the time of auto-deletion", ofSize: 18, weight: .regular, color: .secondText)
        messageLabel.numberOfLines = 0
        
        cancelButton.setCircleButton(height: 50, imageName: "xmark")
        cancelButton.addAction(UIAction { [weak self]_ in
            guard let self = self else { return }
            self.dismiss()
        }, for: .touchUpInside)
        cancelButton.transform = CGAffineTransform(translationX: 0, y: 300)
        
        doneButton.setDefaultButton(withTitle: "Done", height: 50)
        doneButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.dismiss()
        }, for: .touchUpInside)
        
        subview.setSubview(toView: view)
        subview.backgroundColor = .secondBackground
        subview.transform = CGAffineTransform(translationX: 0, y: 300)
        
        
        view.addSubview(backgroundView)
        view.addSubview(subview)
        view.addSubview(cancelButton)
        subview.addSubview(titleLabel)
        subview.addSubview(messageLabel)
        subview.addSubview(pickerView)
        subview.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            cancelButton.bottomAnchor.constraint(equalTo: subview.topAnchor, constant: -25),
            
            titleLabel.topAnchor.constraint(equalTo: subview.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: subview.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            messageLabel.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            
            pickerView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 25),
            pickerView.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            pickerView.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            pickerView.heightAnchor.constraint(equalToConstant: 100),
            
            doneButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 25),
            doneButton.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: 25),
            doneButton.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -25),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    func sendAction(to userID: String) {
        doneButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            NetworkChatService.shared.sendDeleteTimerSignal(userID, deleteTime: selectedOption.index)
            do {
                try LocalChatService.shared.updateDeleteTimer(for: userID, deleteTime: selectedOption.index)
            } catch {}
            self.dismiss()
        }, for: .touchUpInside)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var option: Option?
        switch row {
        case 0: option = .off
        case 1: option = .oneHour
        case 2: option = .oneDay
        default: option = .oneWeek
        }
        return option?.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var option: Option?
        switch row {
        case 0: option = .off
        case 1: option = .oneHour
        case 2: option = .oneDay
        default: option = .oneWeek
        }
        guard let option = option else { return }
        self.selectedOption = option
    }
}
