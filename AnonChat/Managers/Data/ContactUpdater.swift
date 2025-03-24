//
//  ContactUpdater.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 3/24/25.
//

import Foundation

final class ContactUpdater {
    static let shared = ContactUpdater()
    private var updateTimer: Timer?

    private init() {}

    /// Start automatic update Contacts.
    /// - Parameter interval: Interval in second between updates (default 300 s / 5 min).
    func startPeriodicUpdate(interval: TimeInterval = 300) {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateContacts()
        }
    }
    
    /// Stoping update Contact.
    func stopPeriodicUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    
    
    /// Method that sorting out all local Contacts requests updates from the server
    /// and updates data in Realm if they have changed.
    func updateContacts() {
        guard UserManager.shared.currentUID != nil else {
            Logger.log("Error update contacts: no current user", level: .error)
            return
        }
        let localContacts = LocalContactService.shared.fetchContacts()
        let dispatchGroup = DispatchGroup()
        
        for localContact in localContacts {
            dispatchGroup.enter()
            
            NetworkContactService.shared.fetchContact(byUID: localContact.userID) { result in
                switch result {
                case .success(let remoteContact):
                    
                    if localContact.username != remoteContact.username ||
                        localContact.profileImage != remoteContact.profileImage ||
                        localContact.status != remoteContact.status {
                        let updateResult = LocalContactService.shared.updateContact(
                            localContact,
                            newUsername: remoteContact.username,
                            newProfileImage: remoteContact.profileImage,
                            newStatus: remoteContact.status
                        )
                        switch updateResult {
                        case .success():
                            Logger.log("Contact \(localContact.username) updated", level: .debug)
                        case .failure(let error):
                            Logger.log("Contact updating error for \(localContact.username): \(error.localizedDescription)", level: .error)
                        }
                    }
                case .failure(let error):
                    Logger.log("Error fetching contact for \(localContact.username): \(error.localizedDescription)", level: .error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            Logger.log("Contact updating completed", level: .info)
        }
    }
}
