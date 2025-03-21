//
//  ContactsTableView.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/8/25.
//

import UIKit

class ContactsTableView: UITableView, UITableViewDelegate {
    
    enum Section: CaseIterable {
        case savedContacts
        case searchResults
    }

    var diffableDataSource: UITableViewDiffableDataSource<Section, ContactDTO>!
    
    weak var parentVC: MainViewController?
    private let backgroundTableView = BackgroundView()
    
    
    func configure() {

        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.rowHeight = 60
        self.backgroundColor = nil
        self.separatorStyle = .singleLine
        
        self.sectionHeaderTopPadding = 0
        
        backgroundTableView.configure(frame: self.bounds)
        self.register(ContactsTableViewCell.self, forCellReuseIdentifier: "ContactsCell")
        
        diffableDataSource = UITableViewDiffableDataSource<Section, ContactDTO>(tableView: self) { tableView, indexPath, contact in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! ContactsTableViewCell
            
            cell.username.text = contact.username
            cell.status.text = contact.status
            let firstLetter = contact.username.first?.uppercased() ?? ""
            cell.profileImage.setImageWithLabel(imageName: contact.profileImage, text: firstLetter)
            
            return cell
        }
        
        self.dataSource = diffableDataSource
    }
    
    func updateContacts(network: [ContactDTO], local: [ContactDTO], isSearching: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ContactDTO>()
        
        if !local.isEmpty {
            snapshot.appendSections([.savedContacts])
            snapshot.appendItems(local, toSection: .savedContacts)
        }
        
        if !network.isEmpty {
            snapshot.appendSections([.searchResults])
            snapshot.appendItems(network, toSection: .searchResults)
        }
        
        diffableDataSource.apply(snapshot, animatingDifferences: true)

        backgroundTableView.label.text = isSearching ? "Oops, We Can’t Find the Results" : "You don’t have any contacts yet"
        self.backgroundView = local.isEmpty && network.isEmpty ? backgroundTableView : nil
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard diffableDataSource.sectionIdentifier(for: section) != nil else { return nil }
        
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
        guard let sectionType = diffableDataSource.sectionIdentifier(for: section) else { return 0 }
        return diffableDataSource.snapshot().itemIdentifiers(inSection: sectionType).isEmpty ? 0 : 44
    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        parentVC?.coordinator.showProfile(for: contact)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
