//
//  MessagesTableView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import UIKit

class MessagesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    weak var parentView: ChatViewController?
    var data: [MessageDTO] = [] {
        didSet {
            backgroundTableView.isHidden = !self.data.isEmpty
            DispatchQueue.main.async {
                self.reloadData()
                self.scrollToBottom()
            }
        }
    }

    private let backgroundTableView = BackgroundView()
    
    
    func configure() {
        self.dataSource = self
        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = nil
        self.separatorStyle = .none
        
        self.transform = CGAffineTransform(rotationAngle: .pi)
        
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 78
        
        backgroundTableView.configure(frame: self.frame)
        backgroundTableView.label.text = "No Any Messages"
        self.register(MessagesTableViewCell.self, forCellReuseIdentifier: "MessagesCell")
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let rows = self.numberOfRows(inSection: 0)
            guard rows > 0 else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    //MARK: DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath) as! MessagesTableViewCell
        cell.transform = CGAffineTransform(rotationAngle: .pi)
        let message = data[indexPath.row]
        cell.configure(message: message) { [weak self] image in
            guard let self = self,
                  let parentView = parentView else { return }
            parentView.showImage(image: image)
        }
        return cell
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}
