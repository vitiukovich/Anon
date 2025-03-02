//
//  ContactManager.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/27/25.
//

import UIKit


final class ContactManager {
    
    static let shared = ContactManager()
    private init() {}
    
    private let localService =  LocalContactService.shared
    private let networkService =  NetworkContactService.shared

    func fetchLocalContacts() -> [ContactDTO] {
        return localService.fetchContacts().map { $0.toDTO() }
    }
    
    func fetchContact(byUID: String, completion: @escaping (Result<ContactDTO, Error>) -> Void) {
        networkService.fetchContact(byUID: byUID, completion: completion)
    }

    func searchContacts(query: String, completion: @escaping (Result<[ContactDTO], Error>) -> Void) {
        networkService.searchContacts(query: query, completion: completion)
    }

    func saveContact(_ contact: ContactDTO) -> Result<Void, Error>  {
        return localService.saveContact(contact.toContact())
    }

    func deleteContact(_ contact: ContactDTO) -> Result<Void, Error>  {
        return localService.deleteContact(byUsername: contact.username)
    }
    
    func isContactExists(username: String) -> Bool {
        return localService.isContactExists(username: username)
    }
}
