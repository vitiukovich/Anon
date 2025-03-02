//
//  ContactsTableView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/8/25.
//

import UIKit

class ContactsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var localContacts: [ContactDTO] = [] {
        didSet {
            self.reloadData()
        }
    }
    var networkContacts: [ContactDTO] = [] {
        didSet {
            self.reloadData()
        }
    }
    weak var parentVC: MainViewController?
    private let backgroundTableView = BackgroundView()
    
    
    func configure() {
        self.dataSource = self
        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.rowHeight = 60
        self.backgroundColor = nil
        self.separatorStyle = .singleLine
        
        self.sectionHeaderTopPadding = 0
        
        backgroundTableView.configure(frame: self.bounds)
        self.updateEmpty(isSearching: false)
        self.register(ContactsTableViewCell.self, forCellReuseIdentifier: "ContactsCell")
    }
    

    func updateEmpty(isSearching: Bool) {
        backgroundTableView.label.text = isSearching ? "Oops, We Can’t Find the Results" : "You don’t have any contacts yet"
        self.backgroundView = localContacts.isEmpty && networkContacts.isEmpty ? backgroundTableView : nil
    }
    
    
    //MARK: DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return localContacts.count
        case 1: return networkContacts.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! ContactsTableViewCell
        let contact = (indexPath.section == 0) ? localContacts[indexPath.row] : networkContacts[indexPath.row]

        cell.username.text = contact.username
        cell.status.text = contact.status
        let firstLetter = contact.username.first?.uppercased() ?? ""
        cell.profileImage.setImageWithLabel(imageName: contact.profileImage, text: firstLetter)

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .secondBackground

        let label = UILabel()
        label.setDefault(ofSize: 16, weight: .regular, color: .placeholder)
        label.text = section == 0 ? "CONTACTS" : "CLOBAL"
        

        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return localContacts.isEmpty ? 0 : 44
        case 1: return networkContacts.isEmpty ? 0 : 44
        default: return 0
        }
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = (indexPath.section == 0) ? localContacts[indexPath.row] : networkContacts[indexPath.row]
        parentVC?.coordinator.showProfile(for: contact)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
