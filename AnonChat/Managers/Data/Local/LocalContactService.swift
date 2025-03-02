//
//  LocalContactService.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 12/28/24.
//
import Foundation
import RealmSwift

final class LocalContactService{
    static let shared = LocalContactService()
    
    private let realm: Realm
    
    private init(encryptionKey: Data? = nil) {
        do {
            if let key = encryptionKey {
                let config = Realm.Configuration(encryptionKey: key)
                self.realm = try Realm(configuration: config)
            } else {
                self.realm = try Realm()
            }
        } catch {
            fatalError("Error initializing Realm: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: - Fetch Contacts
    func fetchContacts(for currentUID: String) -> [Contact] {
        let results = realm.objects(Contact.self).filter("currentUID == %@", currentUID)
        return Array(results)
    }
    
    func fetchContacts() -> [Contact] {
        guard let currentUID = UserManager.shared.currentUID else { return [] }
        return fetchContacts(for: currentUID)
    }
    
    // MARK: - Save Contact
    func saveContact(_ contact: Contact) -> Result<Void, Error> {
        do {
            try realm.write {
                realm.add(contact, update: .all)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Update Contact
    func updateContact(_ contact: Contact, newUsername: String? = nil, newProfileImage: String? = nil, newStatus: String? = nil, block: Bool? = nil) -> Result<Void, Error> {
        do {
            try realm.write {
                if let newUsername = newUsername {
                    contact.username = newUsername
                }
                if let newProfileImage = newProfileImage {
                    contact.profileImage = newProfileImage
                }
                if let newStatus = newStatus {
                    contact.status = newStatus
                }
                if let block = block {
                    contact.isContactBlocked = block
                }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Delete Contact
    func deleteContact(_ contact: Contact) -> Result<Void, Error> {
        guard !contact.isInvalidated else {
            return .failure(NSError(domain: "LocalManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Contact is invalidated."]))
        }
        
        do {
            try realm.write {
                realm.delete(contact)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func deleteContact(byUsername username: String) -> Result<Void, Error> {
        guard let currentUID = UserManager.shared.currentUID else {
            return .failure(NSError(domain: "LocalManager", code: 405, userInfo: [NSLocalizedDescriptionKey: "Current UID not found."]))
        }
        guard let contact = realm.objects(Contact.self).filter("username == %@ AND currentUID == %@", username, currentUID).first else {
            return .failure(NSError(domain: "LocalManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Contact not found."]))
        }
        return deleteContact(contact)
    }
    
    // MARK: - Search Contacts
    func searchContacts(query: String) -> [Contact] {
        guard let currentUID = UserManager.shared.currentUID else { return [] }
        let contacts = realm.objects(Contact.self)
            .filter("currentUID == %@ AND username CONTAINS[c] %@", currentUID, query)
        return Array(contacts)
    }
    
    // MARK: - Delete All Contacts
    func deleteAllContacts() throws {
        let contacts = realm.objects(Contact.self)
        
        try realm.write {
            realm.delete(contacts)
        }
    }
    
    // MARK: - Helper Methods
    func isContactExists(username: String) -> Bool {
        guard let currentUID = UserManager.shared.currentUID else { return false }
        return realm.objects(Contact.self)
            .filter("username == %@ AND currentUID == %@", username, currentUID)
            .first != nil
    }
}
